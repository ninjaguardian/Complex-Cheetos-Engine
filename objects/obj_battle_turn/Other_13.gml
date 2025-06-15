///@desc Turn End

with (obj_battle_board) {
	if (_board_type != BATTLE_BOARD_TYPES.MAIN) {
		instance_destroy();
	}
}

instance_destroy(obj_battle_bullet);
obj_battle_soul.image_angle = DIR.DOWN;
Battle_SetSoulMode(SOUL.RED);
instance_destroy();

