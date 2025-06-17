var _battle_state = Battle_GetState(), _menu_state = Battle_GetMenu();
if (
	_battle_state == BATTLE_STATE.IN_TURN ||
	_battle_state == BATTLE_STATE.TURN_PREPARATION ||
   (_battle_state == BATTLE_STATE.MENU    && _menu_state != BATTLE_MENU.FIGHT_AIM && 
    _menu_state != BATTLE_MENU.FIGHT_ANIM && _menu_state != BATTLE_MENU.FIGHT_DAMAGE)
   )
	draw_self();
	
if (hp_above && _hp_above_alpha < 1)
	_hp_above_alpha += hp_above_alpha_change;
	
if (!hp_above && _hp_above_alpha > 0)
	_hp_above_alpha -= hp_above_alpha_change;
	
if (_hp_above_alpha != 0) {
	var _color_final = (Player_GetKr() > 0) ? obj_battle_controller.ui_info.color_kr_active : obj_battle_controller.ui_info.color_kr_idle;
	var __text_to_draw = string(Player_GetHp());
	draw_text_color(x-string_width(__text_to_draw)/2+1, y - string_height(string_width) - 10, __text_to_draw, _color_final, _color_final, _color_final, _color_final, _hp_above_alpha);
}

if (global.debug_show_fail_soul) {
	for (var i = 0; i < array_length(global.__failed_soul_pos); i++) {
	    var coords = global.__failed_soul_pos[i];
		draw_sprite_ext(spr_battle_soul,0,coords[0],coords[1],1,1,-90,c_lime,0.5);
	}
}