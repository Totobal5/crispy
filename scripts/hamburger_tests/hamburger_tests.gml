/// @desc Verifies the sample hamburger built by the demo runner.

function test_hamburger_top_bun()
{
	var _hamburger = CrispyTest.vars.hamburger;

	AssertEqual(_hamburger.GetIngredients()[0].GetName(), "bun", "Expecting 'bun' as hamburger's top ingredient");
}

function test_hamburger_bottom_bun()
{
	var _hamburger = CrispyTest.vars.hamburger;
	var _last_index = _hamburger.GetIngredientNumber() - 1;

	AssertEqual(
		_hamburger.GetIngredients()[_last_index].GetName(),
		"bun",
		"Expecting 'bun' as hamburger's bottom ingredient"
	);
}

function test_hamburger_number_of_ingredients()
{
	var _count = CrispyTest.vars.hamburger.GetIngredientNumber();

	AssertEqual(_count, 6, $"hamburger is expected to have only 6 ingredients, not {string(_count)}");
}

function test_hamburger_is_not_gluten_free()
{
	AssertFalse(CrispyTest.vars.hamburger.IsGlutenFree(), "hamburger contains non gluten-free ingredients");
}

function test_hamburger_has_pickles()
{
	AssertTrue(CrispyTest.vars.hamburger.HasIngredient("pickles"), "You forgot the pickles!");
}
