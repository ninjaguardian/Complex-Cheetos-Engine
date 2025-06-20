#region Invincibility
if (global.inv > 0)
{
	global.inv--;
	if (Player_GetInv() > 3)
	{
		if (image_speed == 0)
		{
			image_speed = 1/2;
			image_index = 1;
		}
	}
}
else if (image_speed != 0)
{
	image_speed = 0;
	image_index = 0;
}
#endregion

#region Soul Movement
var _battle_state = Battle_GetState(), _menu_state = Battle_GetMenu();
if (_battle_state == BATTLE_STATE.MENU && _menu_state == BATTLE_MENU.BUTTON)
{
	var _button_pos = obj_battle_controller.ui_button.position,
		_button_scale = obj_battle_controller.ui_button.scale,
		_button = Battle_GetMenuChoiceButton();
	x = lerp(x, _button_pos[_button * 2] - (38 * _button_scale[_button]), 1/3);
	y = lerp(y, _button_pos[_button * 2 + 1] + 1, 1/3);
}
if (_battle_state == BATTLE_STATE.TURN_PREPARATION || _battle_state == BATTLE_STATE.IN_TURN)
{
	image_angle = posmod(image_angle, 360);
	var _angle = image_angle,
		_angle_compensation = (_angle + 90) % 360;
	
	var _hspeed = (!hor_lock) ? CHECK_HORIZONTAL : 0,
		_vspeed = (!ver_lock) ? CHECK_VERTICAL   : 0,
		_mspeed = (Player_GetSpdTotal() / (CHECK_CANCEL + 1));
	
	var _x_offset = sprite_width / 2,
		_y_offset = sprite_height / 2;
	
	#region Board variables & follow
	var _board_exists = instance_exists(global.main_battle_board);
	if (_board_exists)
	{
		var _board = global.main_battle_board,
			_board_x = _board.x,
			_board_y = _board.y,
			_board_angle = posmod(_board.image_angle, 360),
			_board_dir = _board_angle div 90,
			_board_thickness = _board.frame_thickness;
	
		if (follow_board)
		{
			x += _board_x - _board.xprevious;
			y += _board_y - _board.yprevious;
		}
	}
	#endregion

	switch (mode)
	{
		case SOUL.RED:  #region
			if (!hor_lock)
				x += (_hspeed * _mspeed) * (input_rotateable ? dcos(_angle_compensation) : 1);
			if (!ver_lock)
				y += (_vspeed * _mspeed) * (input_rotateable ? dcos(_angle_compensation) : 1);
			break;
		#endregion
			
		case SOUL.BLUE:	#region
			var _jump_input = 0,
				_move_input = 0;
			
			var _on_ground = false,
				_on_ceil = false,
				_on_platform = false;
		
			var _fall_spd = fall_spd,
				_fall_grav = fall_grav;
		
			#region Soul gravity
			if (_fall_spd < 4 && _fall_spd > 0.25)
				_fall_grav = 0.15;
			else if (_fall_spd <= 0.25 && _fall_spd > -0.5)
				_fall_grav = 0.05;
			else if (_fall_spd <= -0.5 && _fall_spd > -2)
				_fall_grav = 0.125;
			else if (_fall_spd <= -2)
				_fall_grav = 0.05;
	
			_fall_spd += (_fall_grav * fall_multi);
			#endregion
			
			#region Position calculation
			var _small_offset = 0.001,
				_displace_x = lengthdir_x(_x_offset+_small_offset, _angle),
				_displace_y = lengthdir_y(_y_offset+_small_offset, _angle);
			
			_on_ground = !scr_point_in_battle_box(x + _displace_x, y + _displace_y, 0);
			_on_ceil = !scr_point_in_battle_box(x - _displace_x, y - _displace_y, 0);
			#endregion
			
			#region Collision processing
			var _platform_check_position = array_create(4, 0);
			#region Input and collision check of different directions of soul
			if (_angle >= 45 && _angle <= 135)
			{
				_platform_check_position[2] = -10;
				_platform_check_position[3] = -_y_offset;
				
				_jump_input = CHECK_DOWN;
				_move_input = _hspeed * -_mspeed;
			}
			else if (_angle >= 225 && _angle <= 315)
			{
				_platform_check_position[2] = _y_offset + 1;
				_platform_check_position[3] = _y_offset;
				
				_jump_input = CHECK_UP;
				_move_input = _hspeed * _mspeed;
			}
			else if (_angle > 135 && _angle < 225)
			{
				_platform_check_position[0] = -10;
				_platform_check_position[1] = _x_offset;
				
				_jump_input = CHECK_RIGHT;
				_move_input = _vspeed * _mspeed;
			}
			else if (_angle < 45 || _angle > 315)
			{
				_platform_check_position[1] = _x_offset + 1;
				_platform_check_position[0] = -_x_offset;
				
				_jump_input = CHECK_LEFT;
				_move_input = _vspeed * -_mspeed;
			}
			#endregion
			
			// If the board doesn't exist, it will never be on the ground nor touching the ceiling
			if (!_board_exists)
			{
				_on_ground = false;
				_on_ceil = false;
			}

			// Platform checking
			var _relative_x = x + _platform_check_position[0],
				_relative_y = y + _platform_check_position[2];
			
			platform_check = instance_position(_relative_x, _relative_y, obj_battle_platform);
			// If the soul is on a platform, stop the falling
			if (position_meeting(_relative_x, _relative_y, obj_battle_platform) && _fall_spd >= 0)
			{
				_on_platform = true;
				while position_meeting(x + _platform_check_position[1], y + _platform_check_position[3], obj_battle_platform)
				{
					x -= lengthdir_y(0.1, _angle_compensation);
					y -= lengthdir_x(0.1, _angle_compensation);
				}
			}
			
			if (instance_exists(platform_check))
			{
				var _soul_x = x, _soul_y = y;
				// If the platform is sticky, carry the soul
				with (platform_check)
				{
					if (sticky)
					{
						_soul_x += xdelta;
						_soul_y += ydelta;
					}
				}
				x = _soul_x; y = _soul_y;
			}
			#endregion
			
			#region Soul slamming (or some might call this soul throwing)
			if (_on_ground || _on_platform || (_fall_spd < 0 && _on_ceil))
			{
				if (slam)
				{
					slam = false;
					Camera_Shake(global.slam_power / 2, global.slam_power / 2, 1, 1, 1, 1, true, true);
				
					if (global.slam_damage)
					{
						if (Player_GetHp() > 1)
							Player_Hurt(1);
						else
							Player_SetHp(1);
					}
			
					audio_stop_sound(snd_impact);
					audio_play_sound(snd_impact, 50, false);
				}
				_fall_spd = ((_on_ground || _on_platform) && _jump_input) ? -3 : 0;
			}
			else if (!_jump_input && _fall_spd < -0.5)
				_fall_spd = -0.5;
			#endregion
			
			// Rotate the movement by the soul's angle
			var _move_x = lengthdir_x(_move_input, _angle_compensation) - lengthdir_y(_fall_spd, _angle_compensation),
				_move_y = lengthdir_y(_move_input, _angle_compensation) + lengthdir_x(_fall_spd, _angle_compensation);
			
			on_ground = _on_ground;
			on_ceil = _on_ceil;
			on_platform = _on_platform;
	
			fall_spd = _fall_spd;
			fall_grav = _fall_grav;
	
			// Finalize movement
			if (moveable)
			{
				x += _move_x;
				y += _move_y;
			} 
			break;
		#endregion
	}
	#region Soul clamping (aka the soul stay inside the board)
	// Collision check for the main bullet board
	if (_board_exists) {
	    var arr = scr_clamp_to_battle_box(x, y, xprevious, yprevious, max(sprite_width, sprite_height)/2, global.main_battle_board.x, global.main_battle_board.y);
	    x = arr[0];
	    y = arr[1];
	}
	#endregion
	
	image_angle = _angle;
}
#endregion
