#region	Public Variables
depth = DEPTH_BATTLE.BOARD;
image_alpha = 1;

x = BATTLE_BOARD.X;
y = BATTLE_BOARD.Y;

up = BATTLE_BOARD.UP;
down = BATTLE_BOARD.DOWN;
left = BATTLE_BOARD.LEFT;
right = BATTLE_BOARD.RIGHT;

bg_alpha = 1;
bg_color = c_black;
#endregion

#region Main Only
if (_board_type == BATTLE_BOARD_TYPES.MAIN) {
	global.main_battle_board = id;
	_surface_mask = -1;
	_and_mask = -1;
	
	_shd_mask_clip_mask =	 shader_get_uniform(shd_mask_clip, "u_mask");
	_shd_mask_clip_bgcolor = shader_get_uniform(shd_mask_clip  , "u_bgcolor");

	_shd_mask_outline_mask =	shader_get_uniform(shd_mask_outline, "u_mask");
	_shd_mask_outline_texel =	shader_get_uniform(shd_mask_outline, "u_texelSize");
	_shd_mask_outline_color =	shader_get_uniform(shd_mask_outline, "u_outlinecolor");
	_shd_mask_outline_radius =	shader_get_uniform(shd_mask_outline, "u_outlineRadius");
	_shd_mask_outline_mode =	shader_get_uniform(shd_mask_outline, "u_mode");
	
	outline_mode = 2; //0: square, 1: diamond, 2: circle

	frame_thickness = 5;
}
#endregion

array_push(global.battle_boards, id);