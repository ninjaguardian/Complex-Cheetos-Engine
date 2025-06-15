if (_board_type != BATTLE_BOARD_TYPES.MAIN) {
	return
}

#region Board's Attributes calculation
//var _angle = image_angle,
//	_alpha = image_alpha,
//	_color = image_blend;

//// Up - Down - Left - Right
//var _u = up, _d = down, _l = left, _r = right;

//// Frame
//var _fx = __frame_x,
//	_fy = __frame_y,
//	_fw = __frame_width,
//	_fh = __frame_height,
//	_ft = frame_thickness;

//// Board measures (Width - Height)
//var	_bg_x = __bg_x,
//	_bg_y = __bg_y,
//	_bg_w = __bg_width,
//	_bg_h = __bg_height,
//	_bg_c = bg_color,
//	_bg_a = bg_alpha,
//	_bg_dw = (_l + _r) + (_ft * 2),
//	_bg_dh = (_u + _d) + (_ft * 2);

//// Background
//__point_xy(x - _l, y - _u);
//_bg_x = __point_x;
//_bg_y = __point_y;
//_bg_w = _l + _r;
//_bg_h = _u + _d;

//// Up
//__point_xy(x - _l - _ft, y - _u - _ft);
//_fx[0] = __point_x;
//_fy[0] = __point_y;
//_fw[0] = _bg_dw;
//_fh[0] = _ft;

//// Down
//__point_xy(x - _l - _ft, y + _d);
//_fx[1] = __point_x;
//_fy[1] = __point_y;
//_fw[1] = _bg_dw;
//_fh[1] = _ft;

//// Left
//__point_xy(x - _l - _ft, y - _u - _ft);
//_fx[2] = __point_x;
//_fy[2] = __point_y;
//_fw[2] = _ft;
//_fh[2] = _bg_dh;

//// Right
//__point_xy(x + _r, y - _u - _ft);
//_fx[3] = __point_x;
//_fy[3] = __point_y;
//_fw[3] = _ft;
//_fh[3] = _bg_dh;

//__frame_x = _fx;
//__frame_y = _fy;
//__frame_width = _fw;
//__frame_height = _fh;

//__bg_x = _bg_x;
//__bg_y = _bg_y;
//__bg_width = _bg_w;
//__bg_height = _bg_h;
//bg_color = _bg_c;
//bg_alpha = _bg_a;
#endregion

#region Clipping Logic handling
#region Arbitrary Clipping via surface
/*
if (!surface_exists(surface_mask))
    surface_mask = surface_create(640, 480);
	
surface_set_target(surface_mask);
draw_clear(c_black);
gpu_set_blendmode(bm_subtract);

// Cut out shapes out of the mask-surface
draw_sprite_ext(spr_pixel, 0, _bg_x, _bg_y, _bg_w, _bg_h, _angle, c_white, 1);
// 

gpu_set_blendmode(bm_normal);
surface_reset_target();

if (!surface_exists(surface_clip))
	surface_clip = surface_create(640, 480);

// Start drawing
surface_set_target(surface_clip);
draw_clear_alpha(c_black, 0);

// Draw things relative to clip-surface
draw_sprite_ext(spr_pixel, 0, 0, 0, 640, 480, 0, _bg_c, _bg_a);
Battle_BoardDraw();
//

// Cut out the mask-surface from it
gpu_set_blendmode(bm_subtract);
draw_surface(surface_mask, 0, 0);
gpu_set_blendmode(bm_normal);

// Finish and draw the clip-surface itself
surface_reset_target();
draw_surface(surface_clip, 0, 0);
*/
#endregion

#region Arbitrary Clipping via shader
if (!surface_exists(surface_mask))
    surface_mask = surface_create(640, 480);

surface_set_target(surface_mask);
	draw_clear_alpha(c_black, 0);
	// Cut the shape(s) out of the mask-surface
    // For each instance of obj_battle_board with type MAIN or OR:
    with (obj_battle_board) {
        if (_board_type == BATTLE_BOARD_TYPES.MAIN || _board_type  == BATTLE_BOARD_TYPES.OR) {
            // Compute this instance’s four corners in screen coordinates.
            // You can replicate your __point_xy logic here (or factor into a script):
            // Let center = (x, y), angle = image_angle, sides = up/down/left/right.

            // Example: compute the four corners of the axis-aligned rectangle before rotation:
            //var left = up; // careful: your vars: up is top offset, left is left offset, etc.
            // Actually: corners: (x - left, y - up), (x + right, y - up), (x + right, y + down), (x - left, y + down).
            var cx = x, cy = y;
            var a = image_angle;

            // Helper inline: rotate a point (px,py) around (cx,cy) by angle a:
            // Using your __point_xy approach:
            // Top-left
            var dx = x - left - cx, dy = y - up - cy;   // but x - left - cx == -left, same
            // but simpler: call a small function or inline lengthdir:
            // However, since lengthdir expects length and angle, use:
            // rotated_x = cx + lengthdir_x(px - cx, a) - lengthdir_y(py - cy, a); etc.
            // To avoid confusion, factor your __point_xy into a script that returns (rx,ry).
            // Assume you have a script: scr_rotate_point(px, py, cx, cy, a) returning [rx, ry].
            var corns = scr_get_rotated_corners(left, right, up, down, cx, cy, a);
            // corns is an array of 4 points: [(x1,y1), (x2,y2), ...] in order.

            // Now draw the polygon white. GML has no direct polygon fill primitive,
            // but you can draw it via draw_primitive_begin/primitives or by using draw_vertex for a triangle fan.
            draw_set_alpha(1);
			draw_set_color(c_white);
			gpu_set_blendmode(bm_normal);
            // For simpler: use draw_primitive:
            draw_primitive_begin(pr_trianglefan);
	            // Center for fan: average of corners (optional)
	            var avgx = (corns[0].x + corns[1].x + corns[2].x + corns[3].x) / 4;
	            var avgy = (corns[0].y + corns[1].y + corns[2].y + corns[3].y) / 4;
				
	            draw_vertex(avgx, avgy);
	            for (var i = 0; i < 4; i++) {
	                draw_vertex(corns[i].x, corns[i].y);
	            }
	            // close back to first corner
	            draw_vertex(corns[0].x, corns[0].y);
            draw_primitive_end();
        }
    }
surface_reset_target();

#endregion
#endregion