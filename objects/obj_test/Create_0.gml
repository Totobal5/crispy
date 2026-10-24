/// @desc Builds the Crispy runner and the demo suites used by the report overlay.

runner = new CrispyRunner("runner");

// Collected output of the run, capped so the overlay stays responsive.
results = ds_list_create();
results_max = 255;

var _results = results;
var _results_max = results_max;

runner.Output(function(_message)
{
	show_debug_message(_message);

	var _lines = string_split(_message, "\n");
	var _len = array_length(_lines);

	if (_len == 0)
	{
		ds_list_insert(_results, 0, _message);
	}
	else
	{
		// One visual row per line keeps the draw and scroll logic accurate.
		for (var i = 0; i < _len; ++i)
		{
			ds_list_insert(_results, 0, _lines[i]);
		}
	}

	while (ds_list_size(_results) > _results_max)
	{
		ds_list_delete(_results, _results_max - 1);
	}
});

gui_test_suite = new CrispySuite("gui_suite");
runner.AddTestSuite(gui_test_suite);
runner.Discover(gui_test_suite, "test_gui_box");

hamburger_suite = new CrispySuite("hamburger_suite");

hamburger_suite.SetUp(function()
{
	var _ingredients = [
		new Ingredient("bun"),
		new Ingredient("pickles", true),
		new Ingredient("tomato", true),
		new Ingredient("lettuce", true),
		new Ingredient("patty"),
		new Ingredient("bun"),
	];

	CrispyTest.vars.hamburger = new Food("hamburger", _ingredients);
});

runner.AddTestSuite(hamburger_suite);
runner.Discover(hamburger_suite, "test_hamburger_");

food_suite = new CrispySuite("food_suite");
runner.AddTestSuite(food_suite);
runner.Discover(food_suite, "test_food_");

crispy_self_test_suite = new CrispySuite("crispy_self_test_suite");
runner.AddTestSuite(crispy_self_test_suite);
runner.Discover(crispy_self_test_suite, "test_crispy_");

can_run_tests = true;

// Info panel content and controls.
padding = 10;
info_text = "Crispy " + CRISPY_VERSION + "\n\n";
info_text += "Test results are displayed below and in the Output Window.\n";
info_text += "Press \"R\" to re-run tests.\n";
info_text += "Press \"C\" to clear test results.\n";
info_text += "Use mouse wheel or arrow keys to navigate test results.";
info_text_y = room_height - padding;
info_box = new GuiBox(1, 1, room_width - 2, padding * 2 + string_height(info_text) - 1);

// Scrolling state of the results panel.
scroll_position = 0;
text_height = string_height("W");

results_box = new GuiBox(info_box.GetX1(), info_box.GetY2() + 3, info_box.GetX2(), room_height - 2);

// Dracula palette.
colors = {
	background: #282a36,
	current_line: #44475a,
	selection: #44475a,
	foreground: #f8f8f2,
	comment: #6272a4,
	cyan: #8be9fd,
	green: #50fa7b,
	orange: #ffb86c,
	pink: #ff79c6,
	purple: #bd93f9,
	red: #ff5555,
	yellow: #f1fa8c,
};
