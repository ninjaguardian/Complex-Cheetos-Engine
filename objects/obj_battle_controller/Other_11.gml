/// @description UI - Battle Info
with (ui_info)
{
	if (image_alpha <= 0)
		exit;
		
	var _color_final = image_blend, _alpha_final = image_alpha;
	
	var _kr_enable = global.kr_enable;
	
	var _bar_hp_max = hp_max * bar_scale,
		_bar_hp = (hp / hp_max) * _bar_hp_max,
		_bar_kr = (kr / hp_max) * _bar_hp_max;
		
	// Name - LV Font
	draw_set_font(font_mars_needs_cunnilingus);
	
	// Name Label
	_alpha_final = image_alpha * alpha_name;
	if (_alpha_final > 0)
	{
		_color_final = color_name;
		draw_text_color(x, y, name, _color_final, _color_final, _color_final, _color_final, _alpha_final);
	}
	
	// LV (Label - Counter)
	_alpha_final = image_alpha * alpha_lv;
	if (_alpha_final > 0)
	{
		var _lv_icon = "   LV ";
		
		var _lv_icon_x = x + string_width(name),
			_lv_counter_x = _lv_icon_x + string_width(_lv_icon);
			
		// Label
		_color_final = color_lv_label;
		draw_text_color(_lv_icon_x, y, _lv_icon, _color_final, _color_final, _color_final, _color_final, _alpha_final);
		// Counter
		_color_final = color_lv;
		draw_text_color(_lv_counter_x, y, lv, _color_final, _color_final, _color_final, _color_final, _alpha_final);
	}
	
	// Icon Font (font for HP, KR label)
	draw_set_font(font_ut_hp);
	
	// HP Label
	_alpha_final = image_alpha * alpha_hp_label;
	if (_alpha_final > 0)
	{
		_color_final = color_hp_label;
		draw_text_color(x + 212, y + 5, hp_label, _color_final, _color_final, _color_final, _color_final, _alpha_final);
	}
	
	// HP and Max HP bars
	var _surf_bar_hp_max = round(_bar_hp_max);
	if (!surface_exists(surf_hp_mask)) {
		surf_hp_mask = surface_create(_surf_bar_hp_max, 20);
	} else if (surface_get_width(surf_hp_mask) != _surf_bar_hp_max) {
		surface_free(surf_hp_mask);
		surf_hp_mask = surface_create(_surf_bar_hp_max, 20);
	}
	surface_set_target(surf_hp_mask);
	draw_clear_alpha(c_black, 0);
	
	_alpha_final = image_alpha * alpha_bars;
	if (_alpha_final > 0)
	{
		// Max HP (background bar)
		_color_final = color_hp_max_bar;
		draw_sprite_ext(spr_pixel, 0, 0, 0, _bar_hp_max, 20, 0, _color_final, _alpha_final);
		// HP
		_color_final = color_hp_bar;
		draw_sprite_ext(spr_pixel, 0, 0, 0, _bar_hp, 20, 0, _color_final, _alpha_final);
	}
	
	var _kr = round(kr);
	_color_final = (_kr > 0) ? color_kr_active : color_kr_idle;
	if (_kr_enable)
	{
		_alpha_final = image_alpha * alpha_kr;
		if (_alpha_final > 0)
		{
			// Draw the bar
			if (_kr > 0)
				draw_sprite_ext(spr_pixel, 0, _bar_hp + 1, 0, max(-_bar_kr, -_bar_hp) - 1, 20, 0, _color_final, _alpha_final);
			// Draw icon
			surface_reset_target();
			draw_text_color(x + 245 + _bar_hp_max + 10, y + 5, kr_label, _color_final, _color_final, _color_final, _color_final, _alpha_final);
			surface_set_target(surf_hp_mask);
		}
	}
	
	gpu_set_blendmode(bm_subtract);
	
	draw_sprite_ext(spr_battle_hp, 0, 0, 0, _bar_hp_max / sprite_get_width(spr_battle_hp), 20 / sprite_get_height(spr_battle_hp), 0, c_white, 1);
	
	gpu_set_blendmode(bm_normal);
	surface_reset_target();
	
	draw_surface(surf_hp_mask, x + 245, y);
	
	// Counter Font (font for HP counter)
	draw_set_font(font_mars_needs_cunnilingus);
		
	// Zeropadding
	var _counter_hp = $"{(round(hp) < 10) ? "0" : ""}{round(hp)}";
	var _counter_hp_max = $"{(round(hp_max) < 10) ? "0" : ""}{round(hp_max)}";
	
	// The commented lines of code below supports multiple digits for Zeropadding base on the amount of number max hp has.
	// It is an option as a replacement for the condition above, though it's not to our preferences.
	// var _counter_hp = string_replace_all(string_format(round(hp), string_length(string(hp_max)), 0), " ", "0");

	// Draw the HP counter
	_alpha_final = image_alpha * alpha_counter;
	if (_alpha_final > 0)
	{
		var _ui_x_offset = (_kr_enable ? (20 + string_width(kr_label)) : 15);
		draw_text_color(x + 245 + _bar_hp_max + _ui_x_offset, y, $"{_counter_hp} / {_counter_hp_max}", _color_final, _color_final, _color_final, _color_final, _alpha_final);
	}
}