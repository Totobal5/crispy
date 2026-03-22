// Create CrispyRunner
runner = new CrispyRunner("runner");

// Test results list
results = ds_list_create();
results_max = 255;

// Override Output to save results to ds_list
runner.__Output = method(self, function(_message) {
	show_debug_message(_message);

	var _lines = string_split(_message, "\n");
	var _len = array_length(_lines);

	if (_len == 0)
	{
		ds_list_insert(results, 0, _message);
	}
	else
	{
		// Insert one visual row per line so draw and scroll logic stay accurate.
		for (var _i = 0; _i < _len; ++_i)
		{
			ds_list_insert(results, 0, _lines[_i]);
		}
	}
	
    while (ds_list_size(results) > results_max) 
    {
		ds_list_delete(results, results_max - 1);
	}
});

// Create GUI elements CrispySuite
gui_test_suite = new CrispySuite("gui_suite");
// Add GUI elements CrispySuite to CrispyRunner
runner.AddTestSuite(gui_test_suite);
// Discover GUI element tests
runner.Discover(gui_test_suite, "test_gui_box");

// Create hamburger CrispySuite
hamburger_suite = new CrispySuite("hamburger_suite");
// Set up hamburger for tests
hamburger_suite.SetUp(function() {
	var _ingredients = [
		new Ingredient("bun"),
		new Ingredient("pickles", true),
		new Ingredient("tomato", true),
		new Ingredient("lettuce", true),
		new Ingredient("patty"),
		new Ingredient("bun")
	];
	CrispyTest.vars.hamburger = new Food("hamburger", _ingredients);
});

// Add hamburger CrispySuite to CrispyRunner
runner.AddTestSuite(hamburger_suite);
// Discovering hamburger tests
runner.Discover(hamburger_suite, "test_hamburger_");

// Create Food CrispySuite
food_suite = new CrispySuite("food_suite");
// Add Food CrispySuite to CrispyRunner
runner.AddTestSuite(food_suite);
// Discovering Food tests
runner.Discover(food_suite, "test_food_");

// Create Crispy Self Test CrispySuite
crispy_self_test_suite = new CrispySuite("crispy_self_test_suite");
// Add Crispy Self Test CrispySuite to CrispyRunner
runner.AddTestSuite(crispy_self_test_suite);
// Discovering Crispy Self Tests
runner.Discover(crispy_self_test_suite, "test_crispy_");

// Flag for running tests
can_run_tests = true;

// Setting up text for Crispy info and controls
padding = 10;
info_text = CRISPY_NAME + " " + CRISPY_VERSION + "    " + CRISPY_DATE + "\n\n";
info_text += "Test results are displayed below and in the Output Window.\n";
info_text += "Press \"R\" to re-run tests." + "\n";
info_text += "Press \"C\" to clear test results." + "\n";
info_text += "Use mouse wheel or arrow keys to navigate test results.";
info_text_y = room_height - padding;
info_box = new GuiBox(1, 1, room_width - 2, padding * 2 + string_height(info_text) - 1);

// Test results scrolling
scroll_position = 0;
text_height = string_height("W");

results_box = new GuiBox(info_box.x1, info_box.y2 + 3, info_box.x2, room_height - 2);


// Defining colors
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
	yellow: #f1fa8c
}
