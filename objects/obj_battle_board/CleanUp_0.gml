if (_board_type == BATTLE_BOARD_TYPES.MAIN) {
	if (surface_exists(_surface_mask))
		surface_free(_surface_mask);
	if (surface_exists(_and_mask))
		surface_free(_and_mask);
}