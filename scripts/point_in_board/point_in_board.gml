/// @desc Test if a world point (px,py) is inside a given board instance’s rotated rectangle.
/// @param {Id.Instance} _inst The board instance.
/// @param {Real} px The x in the point.
/// @param {Real} py The y in the point.
/// @param {Real} margin The board margin.
/// @returns {bool} Is the point in the instance's rotated rectangle?
function scr_point_in_board(_inst, px, py, margin) {
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
 * Function Returns true if (px,py) lies inside at least one obj_battle_board with type MAIN or OR.
 * @param {real} px The x in the point.
 * @param {real} py The y in the point.
 * @param {real} margin The board margin.
 * @returns {bool} Does (px,py) lie inside at least one obj_battle_board with type MAIN or OR?
 */
function scr_point_in_union(px, py, margin) {
	with (obj_battle_board) {
	    if (_board_type == BATTLE_BOARD_TYPES.MAIN || _board_type == BATTLE_BOARD_TYPES.OR) {
	        if (scr_point_in_board(id, px, py, margin)) {
	            // found one
	            return true;
	        }
	    }
	}
	// none found
	return false;
}

/**
 * If (nx,ny) is inside union, returns [nx, ny]. Else returns nearest point on union boundary or [prev_x, prev_y] if none.
 * @param {real} nx New X.
 * @param {real} ny New Y.
 * @param {real} prev_x Previous X.
 * @param {real} prev_y Previous Y.
 * @param {real} margin The board margin.
 * @returns {array<Real>} If (nx,ny) is inside union, returns [nx, ny]. Else returns nearest point on union boundary or [prev_x, prev_y] if none.
 */
function scr_clamp_to_union(nx, ny, prev_x, prev_y, margin) {
	// If inside union of shrunk boards, keep:
	if (scr_point_in_union(nx, ny, margin)) {
	    return [nx, ny];
	}

	var best_x = prev_x;
	var best_y = prev_y;
	var best_dist2 = sqr(nx - prev_x) + sqr(ny - prev_y);

	// Loop boards
	with (obj_battle_board) {
	    if (!(_board_type == BATTLE_BOARD_TYPES.MAIN || _board_type == BATTLE_BOARD_TYPES.OR)) continue;

	    var bx = x, by = y, a = image_angle;
	    // Shrink sides
	    var left2 = left - margin; if (left2 < 0) left2 = 0;
	    var right2 = right - margin; if (right2 < 0) right2 = 0;
	    var up2 = up - margin; if (up2 < 0) up2 = 0;
	    var down2 = down - margin; if (down2 < 0) down2 = 0;

	    // Inverse rotate new point into local:
	    var dx = nx - bx, dy = ny - by;
	    var ca = dcos(a), sa = dsin(a);
	    var lx = dx * ca + dy * sa;
	    var ly = -dx * sa + dy * ca;

	    // Clamp local to shrunk rect:
	    var clx = lx, cly = ly;
	    var on_edge = false;
	    if (lx < -left2) { clx = -left2; on_edge = true; }
	    else if (lx > right2) { clx = right2; on_edge = true; }
	    if (ly < -up2) { cly = -up2; on_edge = true; }
	    else if (ly > down2) { cly = down2; on_edge = true; }
	    if (!on_edge) continue; // projection falls inside shrunk rect interior: either nx,ny was inside this board, or no useful edge

	    // Back to world:
	    var wx = bx + clx * ca - cly * sa;
	    var wy = by + clx * sa + cly * ca;

	    // Ensure candidate not inside another shrunk board:
	    var inside_other = false;
	    with (obj_battle_board) {
	        if (id == other.id) continue;
	        if (_board_type == BATTLE_BOARD_TYPES.MAIN || _board_type == BATTLE_BOARD_TYPES.OR) {
	            if (scr_point_in_board(id, wx, wy, margin)) {
	                inside_other = true;
	                break;
	            }
	        }
	    }
	    if (inside_other) continue;

	    var d2 = sqr(nx - wx) + sqr(ny - wy);
	    if (d2 < best_dist2) {
	        best_dist2 = d2;
	        best_x = wx;
	        best_y = wy;
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
function scr_find_board_under(px, py, margin) {
    var best = noone;
    var bestGap = 1000000000;
    with (obj_battle_board) {
        if (_board_type != BATTLE_BOARD_TYPES.MAIN && _board_type != BATTLE_BOARD_TYPES.OR) continue;
        var arr = scr_world_to_local(id, px, py);
        var lx = arr[0], ly = arr[1];
        // Check horizontal alignment: lx between -left and right
        if (lx >= -left && lx <= right) {
            var gap = ly + margin + up; 
            // If gap >= 0, soul’s feet are below top edge (i.e. penetrating or on), treat as on-board.
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
    return best;
}