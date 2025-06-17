// feather ignore GM1062

/**
 * @func Battle_IsBoardTransforming([instance])
 * @desc Return if the battle board is resizing or not.
 * @param {id.instance<obj_battle_board>} [instance] Battle board instance or 'noone' to use main. (Default: noone)
 * @returns {bool} Is the battle board resizing?
 */
function Battle_IsBoardTransforming(_inst = noone) {
	if (_inst == noone || !instance_exists(_inst)) _inst = global.main_battle_board;
	return (instance_exists(_inst)) ? (TweenExists({target: _inst})) : false;
}

///@func Battle_SetBoardSize(up, down, left, right, [duration], [ease], [delay], [instance])
///@desc Set the size of the battle board (in pixel of course).
///@param {Real}				up				The top side of the board. (Default: 65)
///@param {Real}				down			The bottom side of the board. (Default: 65)
///@param {Real}				left			The left side of the board. (Default: 283)
///@param {Real}				right			The right side of the board. (Default: 283)
///@param {Real}				[duration]		The duration of the transformation in frame. (Default: 25)
///@param {String, Function}	[ease]			The easing string or function for the transformation. (Default: linear)
///@param {Real}				[delay]			The delay before transformation start. (Default: 0)
///@param {id.instance<obj_battle_board>}	[instance]	Battle board instance or 'noone' to use main. (Default: noone)
function Battle_SetBoardSize(_up, _down, _left, _right, _duration = 25, _ease = "", _delay = 0, _inst = noone) {
	if (_inst == noone || !instance_exists(_inst)) _inst = global.main_battle_board;
	with (_inst)
	{
		if (_duration <= 0)
		{ up = _up; down = _up; left = _left; right = _right; }
		else
		{
			var prop = [["up>", _up], ["down>", _down], ["left>", _left], ["right>", _right]],
				i = 0;
			repeat(4)
			{
				TweenFire(id, _ease, 0, off, _delay, _duration, prop[i][0], prop[i][1]);
				i++;
			}
		}
	}
}

///@func Battle_SetBoardAngle(angle, [duration], [ease], [delay], [instance])
///@desc Set the size of the battle board (in pixel of course).
///@param {Real}				angle			The angle to rotate to. (Default: 0)
///@param {Real}				[duration]		The duration of the transformation in frame. (Default: 25)
///@param {String, Function}	[ease]			The easing string or function for the transformation. (Default: linear)
///@param {Real}				[delay]			The delay before transformation start. (Default: 0)
///@param {id.instance<obj_battle_board>}	[instance]	Battle board instance or 'noone' to use main. (Default: noone)
function Battle_SetBoardAngle(_angle, _duration = 25, _ease = "", _delay = 0, _inst = noone) {
	if (_inst == noone || !instance_exists(_inst)) _inst = global.main_battle_board;
	with (_inst)
	{
		if (_duration <= 0)
		{ image_angle = _angle }
		else
		{
			TweenFire(id, _ease, 0, off, _delay, _duration, "image_angle>", _angle);
		}
	}
}

///@func Battle_BoardMaskSet([use_texture], [mask_enable], [instance])
///@desc Set all further drawing to be (only) visible within the board mask.
///@param {Bool}	[use_texture]	Whenever further drawing includes sprite or just primitive draw functions (like draw_line(), draw_rectangle()...). (Default: false)
///@param {Bool}	[mask_enable]	Whenever further drawing will be masked within the board or not. (Default: true)
///@param {id.instance<obj_battle_board>}	[instance]	Battle board instance or 'noone' to use main. (Default: noone)
function Battle_BoardMaskSet(_use_texture = false, _mask_enable = true, _inst = noone) {
	if (_inst == noone || !instance_exists(_inst)) _inst = global.main_battle_board;
	var _mask_shader = (!_use_texture) ? shd_clip_mask_primitive : shd_clip_mask_sprite;
	shader_set(_mask_shader);
	var _u_mask = shader_get_sampler_index(_mask_shader, "u_mask"),
		_u_maskEnable = shader_get_uniform(_mask_shader, "u_maskEnable"),
		_u_rect = shader_get_uniform(_mask_shader, "u_rect");
	
	shader_set_uniform_f(_u_rect, 0, 0, 640, 480);
	shader_set_uniform_f(_u_maskEnable, _mask_enable);
	texture_set_stage(_u_mask, surface_get_texture(_inst.surface_mask));
}

///@func Battle_BoardMaskReset()
///@desc Reset all further drawing from specifically within the board mask back to the screen.
function Battle_BoardMaskReset() {
	shader_reset();
}

/**
 * Adds another battle board.
 * @param {real} x The x position of the board.
 * @param {real} y The y position of the board.
 * @param {any*} type The BATTLE_BOARD_TYPES of the board.
 * @param {real} [up] How far should it extend up? (Default: 0)
 * @param {real} [down] How far should it extend down? (Default: 0)
 * @param {real} [left] How far should it extend left? (Default: 0)
 * @param {real} [right] How far should it extend right? (Default: 0)
 * @param {real} [depth] Instance depth. (Default: 0)
 * @returns {id.instance<obj_battle_board>} The board instance.
 */
function Battle_AddNewBoard(_x, _y, _type, _up = 0, _down = 0, _left = 0, _right = 0, _depth = 0) {
	var _inst = instance_create_depth(_x, _y, _depth, obj_battle_board, {_board_type : _type});
	with (_inst) {
		up = _up;
		down = _down;
		left = _left;
		right = _right;
		x = _x;
		y = _y;
	}
	return _inst;
}

enum BATTLE_BOARD_TYPES {
	MAIN,
	EXCLUDE,
	OR,
	AND
}