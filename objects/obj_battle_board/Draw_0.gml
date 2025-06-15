if (_board_type != BATTLE_BOARD_TYPES.MAIN)
	return

// Drawing the board's background and frame surface
if (surface_exists(__surface_frame))
	draw_surface(__surface_frame, 0, 0);

shader_set(shd_mask_outline);
	texture_set_stage(0, surface_get_texture(surface_mask));
	shader_set_uniform_f(shd_mask_outline_texel,
	    frame_thickness / 640, frame_thickness / 480);
	shader_set_uniform_f(shd_mask_outline_outlinecolor,
	    1,1,1,1);
	// Draw full-screen quad:
	draw_rectangle(0, -1, 640, 480-1, false);
shader_reset();