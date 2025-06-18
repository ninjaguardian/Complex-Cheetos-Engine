// local function to rotate point (px,py) around (cx,cy) by angle a:
/// @desc Internal function
function _scr_get_rotated_corners_rot(px, py, cx, cy, a) {
	var dx = px - cx;
	var dy = py - cy;
	// rotate: rx = cx + dx*cos(a) - dy*sin(a); ry = cy + dx*sin(a) + dy*cos(a).
	// In GML: use dcos, dsin, but they expect degrees. image_angle is in degrees.
	var ca = dcos(a);
	var sa = dsin(a);
	var rx = cx + dx * ca - dy * sa;
	var ry = cy + dx * sa + dy * ca;
	return { x: rx, y: ry };
}

/// @desc Gets the rotated corners for the board.
/// @param {Real} left
/// @param {Real} right
/// @param {Real} up
/// @param {Real} down
/// @param {Real} cx
/// @param {Real} cy
/// @param {Real} a
/// @returns {Array<Struct>} [ {x:..., y:...}, ... ] for the four corners in order (TL, TR, BR, BL).
function scr_get_rotated_corners(left, right, up, down, cx, cy, a) {
	var px1 = cx - left,  py1 = cy - up;    // top-left
	var px2 = cx + right, py2 = cy - up;    // top-right
	var px3 = cx + right, py3 = cy + down;  // bottom-right
	var px4 = cx - left,  py4 = cy + down;  // bottom-left

	var c1 = _scr_get_rotated_corners_rot(px1, py1, cx, cy, a);
	var c2 = _scr_get_rotated_corners_rot(px2, py2, cx, cy, a);
	var c3 = _scr_get_rotated_corners_rot(px3, py3, cx, cy, a);
	var c4 = _scr_get_rotated_corners_rot(px4, py4, cx, cy, a);

	return [c1, c2, c3, c4];
}

/// @desc Test if a world point (px,py) is inside a given board instance's rotated rectangle.
/// @param {Id.Instance} _inst The board instance.
/// @param {Real} px The x in the point.
/// @param {Real} py The y in the point.
/// @param {Real} margin The board margin.
/// @returns {bool} Is the point in the instance's rotated rectangle?
function scr_point_in_board(_inst, px, py, margin) {
	if (_inst == noone || !instance_exists(_inst)) return false;
	var bx = _inst.x;
	var by = _inst.y;
	var left = _inst.left;
	var right = _inst.right;
	var up = _inst.up;
	var down = _inst.down;
	var a = _inst.image_angle;

	// Shrink bounds by margin:
	var left2 = left - margin;
	var right2 = right - margin;
	var up2 = up - margin;
	var down2 = down - margin;
	// If shrinking makes invalid (e.g. margin > half-size), clamp to zero-size:
	if (left2 < 0) left2 = 0;
	if (right2 < 0) right2 = 0;
	if (up2 < 0) up2 = 0;
	if (down2 < 0) down2 = 0;

	// Translate point into board-local coords by inverse rotation
	var dx = px - bx;
	var dy = py - by;
	var ca = dcos(a);
	var sa = dsin(a);
	var local_x = dx * ca + dy * sa;
	var local_y = -dx * sa + dy * ca;

	// Check against shrunk axis-aligned bounds
	if (local_x >= -left2 && local_x <= right2 && local_y >= -up2 && local_y <= down2) {
	    return true;
	} else {
	    return false;
	}
}

/**
 * Function Returns true if (px,py) lies in the battle box.
 * @param {real} px The x in the point.
 * @param {real} py The y in the point.
 * @param {real} margin The board margin.
 * @param {Id.Instance} [exclude] Ignore a certain battle box. (Default: noone)
 * @returns {bool} Does (px,py) lie in the battle box?
 */
function scr_point_in_battle_box(px, py, margin, exclude=noone) {
	var in_board = false;
	for (var i = 0; i < array_length(global.battle_boards); i++) {
	    var instID = global.battle_boards[i];
		if (exclude == instID) continue; 
	    if (instance_exists(instID)) {
	        with (instID) {
				switch (_board_type) {
					case BATTLE_BOARD_TYPES.MAIN:
					case BATTLE_BOARD_TYPES.OR:
				        if (!in_board && scr_point_in_board(id, px, py, margin))
							in_board = true;
						break;
					case BATTLE_BOARD_TYPES.EXCLUDE:
				        if (in_board && scr_point_in_board(id, px, py, -margin+1)) // TODO: test value
							in_board = false;
						break;
					case BATTLE_BOARD_TYPES.AND:
				        if (in_board && !scr_point_in_board(id, px, py, margin)) // TODO: change margin
							in_board = false;
						break;
				}
	        }
	    }
	}
	return in_board;
}


// feather ignore once GM1062

/**
 * Projects world point (nx,ny) onto the nearest point on the boundary of inst's shrunk rectangle.
 * @param {id.instance<obj_battle_board>} inst       The board instance.
 * @param {real} nx       New X.
 * @param {real} ny       New Y.
 * @param {real} margin   Shrink margin.
 * @returns {array<real, bool>} [wx, wy, inside]:
 *   wx,wy = world coordinates of the closest point on the rectangle edge.
 *   inside = bool: true if (nx,ny) was inside the shrunk rect, or false otherwise.
 * If the projection falls exactly inside the shrunk rect interior, we still clamp to nearest edge
 * but inside=true. If (nx,ny) is outside, inside=false.
 */
function scr_project_to_rect_edge(inst, nx, ny, margin) {
    var bx = inst.x, by = inst.y;
    var a  = inst.image_angle;
    var left2  = inst.left  - margin; if (left2 < 0) left2 = 0;
    var right2 = inst.right - margin; if (right2 < 0) right2 = 0;
    var up2    = inst.up    - margin; if (up2 < 0) up2 = 0;
    var down2  = inst.down  - margin; if (down2 < 0) down2 = 0;

    var arrL = scr_world_to_local(inst, nx, ny);
    var lx = arrL[0], ly = arrL[1];

    var inside = (lx >= -left2 && lx <= right2 && ly >= -up2 && ly <= down2);

    // Compute clamp to edge: nearest x-edge or y-edge
    // Compute distances to edges:
    var dist_left   = lx + left2;
    var dist_right  = right2 - lx;
    var dist_top    = ly + up2;
    var dist_bottom = down2 - ly;

    // If outside, some of these may be negative. Still pick the smallest absolute distance?
    // To project onto edge, clamp lx, ly within [-left2, right2] and [-up2, down2].
    var clx = lx, cly = ly;
    // Clamp x:
    if (lx < -left2) clx = -left2;
    else if (lx > right2) clx = right2;
    // Clamp y:
    if (ly < -up2) cly = -up2;
    else if (ly > down2) cly = down2;

    // Now (clx,cly) lies on or inside the shrunk rect.
    if (inside) {
        // Find minimal distance to each edge:
        var dL = abs(dist_left);
        var dR = abs(dist_right);
        var dT = abs(dist_top);
        var dB = abs(dist_bottom);
        var dmin = dL; var edge = 0;
        if (dR < dmin) { dmin = dR; edge = 1; }
        if (dT < dmin) { dmin = dT; edge = 2; }
        if (dB < dmin) { dmin = dB; edge = 3; }
        switch(edge) {
            case 0: clx = -left2; break;
            case 1: clx = right2; break;
            case 2: cly = -up2;   break;
            case 3: cly = down2;  break;
        }
    }
    // If outside, (clx,cly) is already the projection onto the rectangle boundary (or corner).

    var arrW = scr_local_to_world(inst, clx, cly);
    return [arrW[0], arrW[1], inside];
}

/**
 * If (nx,ny) is inside the battle box (MAIN+OR minus EXCLUDE), returns [nx, ny].
 * Else returns nearest point on the boundary of that region, or [prev_x, prev_y] if none.
 * @param {real} nx New X.
 * @param {real} ny New Y.
 * @param {real} prev_x Previous X.
 * @param {real} prev_y Previous Y.
 * @param {real} margin The board margin.
 * @param {real} fallback_x If prev_x is outside the board, go here.
 * @param {real} fallback_y If prev_y is outside the board, go here.
 * @returns {array<Real>} If (nx,ny) is inside the battle box, returns [nx, ny]. Else nearest point on boundary, or [prev_x, prev_y].
 */
function scr_clamp_to_battle_box(nx, ny, prev_x, prev_y, margin, fallback_x, fallback_y) { // TODO: make it instead fallback to a closer point, also if fallback is out of bounds, ur cooked.
	if (scr_point_in_battle_box(nx, ny, margin)) {
        return [nx, ny];
    }
    var best_x = prev_x, best_y = prev_y;
	if (!scr_point_in_battle_box(best_x, best_y, margin)) {
		if (global.debug_show_fail_soul) {
			array_push(global.__failed_soul_pos, [best_x, best_y]);
		}
		best_x = fallback_x; best_y = fallback_y;
	}
    var best_dist2 = 1000000000;

    for (var i = 0; i < array_length(global.battle_boards); i++) {
        var instID = global.battle_boards[i];
        if (!instance_exists(instID)) continue;

		with (instID) {
	        // Project onto this board's shrunk rect edge:
	        var proj = scr_project_to_rect_edge(id, nx, ny, _board_type == BATTLE_BOARD_TYPES.EXCLUDE ? -margin : margin);
	        var wx = proj[0], wy = proj[1], inside = proj[2];

			var isUnion = (_board_type == BATTLE_BOARD_TYPES.MAIN || _board_type == BATTLE_BOARD_TYPES.OR || _board_type == BATTLE_BOARD_TYPES.AND);
			var isExclude  = (_board_type == BATTLE_BOARD_TYPES.EXCLUDE);
			var wantClamp  = (isUnion && inside = false)
			               || (isExclude && inside = true);
			if (!wantClamp) {
			    continue;
			}
			// Now verify candidate lies in allowed area:
			if (!scr_point_in_battle_box(wx, wy, margin)) {
				if (global.debug_show_fail_soul) {
					array_push(global.__failed_soul_pos, [wx, wy]);
				}
			    continue;
			}

	        // Accept candidate if closer
	        var d2 = sqr(nx - wx) + sqr(ny - wy);
	        if (d2 < best_dist2) {
	            best_dist2 = d2;
	            best_x = wx;
	            best_y = wy;
	        }
		}
    }
	
	if (best_dist2 > 1000) { // arbitrary number
		var candidate = scr_find_nearest_inside(nx, ny, margin, 200, 4, 15), // a bit janky and it makes you shake, but it is still better than shooting you across the board.
			c_x = candidate[0], c_y = candidate[1];
		if (sqr(nx - c_x) + sqr(ny - c_y) < best_dist2) {
			return [c_x, c_y];
		}
	}
    return [best_x, best_y];
}


// feather disable GM1045

/**
 * Convert world position (wx,wy) into local coords (lx,ly) for the given board instance
 * @param {Id.Instance} inst Board instance
 * @param {real} wx World x
 * @param {real} wy World y
 * @returns {array<real>} Local coords
 */
function scr_world_to_local(inst, wx, wy) {
	var bx = inst.x;
	var by = inst.y;
	var a = inst.image_angle;
	// Translate
	var dx = wx - bx;
	var dy = wy - by;
	// Inverse rotate by a: 
	var ca = dcos(a), sa = dsin(a);
	// local_x = dx*cos(a) + dy*sin(a)
	// local_y = -dx*sin(a) + dy*cos(a)
	var lx = dx * ca + dy * sa;
	var ly = -dx * sa + dy * ca;
	return [lx, ly];
}

/**
 * Convert local position (lx,ly) into world coords (wx,wy) for the given board instance
 * @param {Id.Instance} inst Board instance
 * @param {real} lx Local x
 * @param {real} ly Local y
 * @returns {array<real>} World coords
 */
function scr_local_to_world(inst, lx, ly) {
	var bx = inst.x;
	var by = inst.y;
	var a = inst.image_angle;
	var ca = dcos(a), sa = dsin(a);
	var wx = bx + lx * ca - ly * sa;
	var wy = by + lx * sa + ly * ca;
	// feather ignore once GM1045
	return [wx, wy];
}

// feather enable GM1045
// feather ignore once GM1062

/// @desc Returns the board instance (MAIN or OR) whose top edge is directly under (px,py), if within horizontal bounds. If multiple overlap, returns the one with smallest vertical gap (ly distance to its down-edge). Else returns noone.
/// @param {real} px X coord
/// @param {real} py y coord
/// @param {real} margin The board margin.
/// @returns {id.instance<obj_battle_board>} Board instance
function scr_find_board_under(px, py, margin) { // TODO: does not support exclude or and. unused anyways :P
    var best = noone;
    var bestGap = 1000000000;
	for (var i = 0; i < array_length(global.battle_boards); i++) {
	    var instID = global.battle_boards[i];
	    if (instance_exists(instID)) {
	        with (instID) {
		        if (_board_type != BATTLE_BOARD_TYPES.MAIN && _board_type != BATTLE_BOARD_TYPES.OR) continue;
		        var arr = scr_world_to_local(id, px, py);
		        var lx = arr[0], ly = arr[1];
		        // Check horizontal alignment: lx between -left and r	ight
		        if (lx >= -left && lx <= right) {
		            var gap = ly + margin + up; 
		            // If gap >= 0, soul's feet are below top edge (i.e. penetrating or on), treat as on-board.
		            // If gap < 0, soul is above board; vertical distance = -gap.
		            if (gap >= 0) {
		                // soul is at or below top: treat as standing (penetration), gap=0
		                gap = 0;
		            } else {
		                gap = -gap;
		            }
		            // Only consider if the soul is not far below bottom: check ly - soul_half_h <= down
		            if (ly - margin <= down) {
		                // Candidate. We want smallest gap.
		                if (gap < bestGap) {
		                    bestGap = gap;
		                    best = id;
		                }
		            }
		        }
	        }
	    }
	}
    return best;
}

/// scr_find_nearest_inside(nx, ny, margin, max_radius, radius_step, angle_step)
/// Returns [x,y] nearest to (nx,ny) that satisfies scr_point_in_battle_box, or [nx,ny] if none found.
/// - margin: board margin passed to scr_point_in_battle_box
/// - max_radius: how far (in pixels) to search
/// - radius_step: increment of radius per loop
/// - angle_step: degrees between samples on each ring
function scr_find_nearest_inside(nx, ny, margin, max_radius, radius_step, angle_step) {
    // If already inside, return immediately
    if (scr_point_in_battle_box(nx, ny, margin)) {
        return [nx, ny];
    }
    var best_x = nx;
    var best_y = ny;
    var found = false;

    // Spiral/radial search: increasing radius
    for (var r = radius_step; r <= max_radius; r += radius_step) {
        // sample around circle at radius r
        for (var ang = 0; ang < 360; ang += angle_step) {
            var cx = nx + lengthdir_x(r, ang);
            var cy = ny + lengthdir_y(r, ang);
            if (scr_point_in_battle_box(cx, cy, margin)) {
                // found a candidate inside
                best_x = cx;
                best_y = cy;
                found = true;
                break;
            }
        }
        if (found) break;
    }
    // if found, best_x/best_y is the first hit (nearest by radius). If you want exact nearest,
    // you could continue scanning the same radius ring to pick minimal distance, or even check smaller offsets.
    // If none found within max_radius, return original or some fallback.
    return found ? [best_x, best_y] : [nx, ny];
}