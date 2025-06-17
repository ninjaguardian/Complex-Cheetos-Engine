if (_board_type != BATTLE_BOARD_TYPES.MAIN) {
	return
}
if (global.debug) {
	draw_surface(surface_mask, 0, 0);
	return;
}

shader_set(shd_mask_clip);
	// Pass uniforms:
	//   texture sampler: mask texture (surface_mask)
	//   background color, possibly as uniform
	//   resolution or texel size if needed
	// Draw a full-screen rectangle or the union bounding box:
	texture_set_stage(0, surface_get_texture(surface_mask));
	shader_set_uniform_i(shd_mask_clip_mask, 0);
	shader_set_uniform_f(shd_mask_clip_bgcolor, 0,1,0,1);
	draw_surface(surface_mask, 0, 0);
shader_reset();

shader_set(shd_mask_outline);
	texture_set_stage(0, surface_get_texture(surface_mask));
	shader_set_uniform_i(shd_mask_outline_mask, 0);
	texture_set_stage(1, sprite_get_texture(spr_battle_board, 0));
	shader_set_uniform_i(shd_mask_outline_border, 1);
	shader_set_uniform_f(shd_mask_outline_borderWidth, 32);
	shader_set_uniform_f(shd_mask_outline_thickness, frame_thickness);
	shader_set_uniform_f(shd_mask_outline_viewSize, room_width, room_height);
	
	draw_sprite_ext(spr_pixel_center, 0, room_width/2, room_height/2, room_width/2, room_height/2, 0, c_white, 1);
shader_reset();