/// @desc Draws the report overlay of the demo runner.

// Results panel.
results_box.Draw(colors.background, false);

var _len = ds_list_size(results);

if (_len != 0)
{
	draw_set_color(colors.foreground);

	var i = 0;
	repeat (_len)
	{
		var _text = results[| i];
		var _offset = (i + 1) * text_height;
		draw_text(results_box.GetX1() + padding, results_box.GetY2() - padding - scroll_position - _offset, _text);

		++i;
	}
}

results_box.Draw(colors.foreground, true);

// Info panel.
info_box.Draw(colors.background, false);
info_box.Draw(colors.foreground, true);
draw_set_color(colors.purple);
draw_text(padding, padding, info_text);
draw_set_color(c_black);
