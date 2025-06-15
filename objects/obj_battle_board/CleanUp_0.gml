//if (surface_exists(surface_clip))
//	surface_free(surface_clip);

if (_board_type == BATTLE_BOARD_TYPES.MAIN && surface_exists(surface_mask))
	surface_free(surface_mask);
