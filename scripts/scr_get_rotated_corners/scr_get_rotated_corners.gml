// local function to rotate point (px,py) around (cx,cy) by angle a:
/// @desc Internal function
function scr_get_rotated_corners_rot(px, py, cx, cy, a) {
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

	var c1 = scr_get_rotated_corners_rot(px1, py1, cx, cy, a);
	var c2 = scr_get_rotated_corners_rot(px2, py2, cx, cy, a);
	var c3 = scr_get_rotated_corners_rot(px3, py3, cx, cy, a);
	var c4 = scr_get_rotated_corners_rot(px4, py4, cx, cy, a);

	return [c1, c2, c3, c4];
}