/// @desc Runs the demo runner and handles the overlay controls.

if (CRISPY_RUN)
{
	if (can_run_tests)
	{
		can_run_tests = false;
		runner.Run();
	}
	else
	{
		if (runner.IsRunning() )
		{
			runner.Update();
		}

		// Re-run the tests.
		if (keyboard_check_pressed(ord("R") ) )
		{
			can_run_tests = true;
			scroll_position = 0;
		}
	}
}

// Clear the collected results.
if (keyboard_check_pressed(ord("C") ) )
{
	if (ds_list_size(results) > 0)
	{
		ds_list_clear(results);
		scroll_position = 0;

		__crispy_alert("Test results cleared.");
	}
}

// Scroll through the results, clamped to the visible rows.
var _wheel_up = mouse_wheel_up() || keyboard_check_pressed(vk_up);
var _wheel_down = mouse_wheel_down() || keyboard_check_pressed(vk_down);
var _scroll_dir = -_wheel_up + _wheel_down;

if (_scroll_dir != 0 && ds_list_size(results) > 0)
{
	var _scroll_multiplier = 2;
	var _amount = _scroll_dir * text_height * _scroll_multiplier;
	var _new_position = scroll_position + _amount;
	var _h = string_height("W");
	var _h_total = _h * ds_list_size(results);
	var _y1 = -_h_total + _h * _scroll_multiplier;
	var _y2 = results_box.GetHeight() - _h * _scroll_multiplier;

	if (_new_position == clamp(_new_position, _y1, _y2) )
	{
		scroll_position = _new_position;
	}
}
