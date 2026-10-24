/// @desc Verifies that the sample Food class validates its constructor arguments.

function test_food_raises_error_when_passing_number_to_name()
{
	AssertRaises(function()
	{
		var _food = new Food(12, []);
	}, "Expected an error to raise when passing a number to Food name.");
}

function test_food_raise_error_value_when_passing_number_to_name()
{
	AssertRaiseErrorValue(function()
	{
		var _food = new Food(12, []);
	}, "Food \"_name\" expected a string, received number.");
}
