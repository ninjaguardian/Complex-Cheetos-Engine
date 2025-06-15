if (_board_type != BATTLE_BOARD_TYPES.MAIN) {
	return
}

shader_set(shd_mask_clip);
	// Pass uniforms:
	//   texture sampler: mask texture (surface_mask)
	//   background color, possibly as uniform
	//   resolution or texel size if needed
	// Draw a full-screen rectangle or the union bounding box:
	texture_set_stage(0, surface_get_texture(surface_mask));
	shader_set_uniform_i(shd_mask_clip_mask, 0);         // Use texture stage 0
	shader_set_uniform_f(shd_mask_clip_bgcolor, 0,1,0,1);
	draw_surface(surface_mask, 0, 0);
shader_reset();

shader_set(shd_mask_outline);
	shader_set_uniform_f(shd_mask_outline_texel,
	    frame_thickness / 640, frame_thickness / 480);
	shader_set_uniform_f(shd_mask_outline_outlinecolor,
	    1,1,1,1);
	// Draw full-screen quad:
	draw_rectangle(0, -1, 640, 480-1, false);
shader_reset();