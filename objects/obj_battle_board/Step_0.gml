if (_board_type != BATTLE_BOARD_TYPES.MAIN) {
	return
}


if (!surface_exists(_and_mask))
    _and_mask = surface_create(room_width, room_height);
	
if (!surface_exists(_surface_mask))
    _surface_mask = surface_create(room_width, room_height);

surface_set_target(_surface_mask);
	draw_clear_alpha(c_black, 0);
	
	for (var i = 0; i < array_length(global.battle_boards); i++) {
	    var instID = global.battle_boards[i];
	    if (instance_exists(instID)) {
	        with (instID) {
				switch (_board_type) {
					case BATTLE_BOARD_TYPES.EXCLUDE:
						gpu_set_blendmode(bm_subtract);
						break;
					case BATTLE_BOARD_TYPES.AND:
						surface_reset_target();
						surface_set_target(other._and_mask);
						draw_clear_alpha(c_black, 0);
						break;
					default:
						break;
				}
				
				#region Main logic
			    var cx = x, cy = y;
			    var a = image_angle;

			    var dx = x - left - cx, dy = y - up - cy;
						
			    var corns = scr_get_rotated_corners(left, right, up, down, cx, cy, a);

			    draw_set_alpha(1);
				draw_set_color(c_white);
			    draw_primitive_begin(pr_trianglefan); // TODO: can this be a draw rectangle?
				    var avgx = (corns[0].x + corns[1].x + corns[2].x + corns[3].x) / 4;
				    var avgy = (corns[0].y + corns[1].y + corns[2].y + corns[3].y) / 4;
				
				    draw_vertex(avgx, avgy);
				    for (var _i = 0; _i < 4; _i++) {
				        draw_vertex(corns[_i].x, corns[_i].y);
				    }
				    draw_vertex(corns[0].x, corns[0].y); // close back to first corner
			    draw_primitive_end();
				#endregion

				switch (_board_type) {
					case BATTLE_BOARD_TYPES.EXCLUDE:
						gpu_set_blendmode(bm_normal);
						break;
					case BATTLE_BOARD_TYPES.AND:
						surface_reset_target();
						surface_set_target(other._surface_mask);
						gpu_set_blendmode_ext(bm_zero, bm_src_alpha);
						draw_surface(other._and_mask, 0, 0);
						gpu_set_blendmode(bm_normal);
						break;
					default:
						break;
				}
			}
		}
	}
surface_reset_target();