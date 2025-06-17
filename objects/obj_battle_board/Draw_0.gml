if (_board_type != BATTLE_BOARD_TYPES.MAIN) {
	return
}
if (global.debug_show_board) {
	draw_surface(_surface_mask, 0, 0);
	return;
}

shader_set(shd_mask_clip);
	texture_set_stage(0, surface_get_texture(_surface_mask));
	shader_set_uniform_i(_shd_mask_clip_mask, 0);
	shader_set_uniform_f(_shd_mask_clip_bgcolor, color_get_red(bg_color), color_get_green(bg_color), color_get_blue(bg_color), bg_alpha);
	draw_surface(_surface_mask, 0, 0);
shader_reset();

shader_set(shd_mask_outline);
	texture_set_stage(0, surface_get_texture(_surface_mask));
	shader_set_uniform_i(_shd_mask_outline_mask, 0);
	shader_set_uniform_f(_shd_mask_outline_texel, 1.0 / room_width, 1.0 / room_height);
	shader_set_uniform_f(_shd_mask_outline_color, 1,1,1,1);
	shader_set_uniform_f(_shd_mask_outline_radius, frame_thickness);
	shader_set_uniform_i(_shd_mask_outline_mode, outline_mode);
		
	draw_rectangle(1, 1, room_width-2, room_height-1, false);
shader_reset();