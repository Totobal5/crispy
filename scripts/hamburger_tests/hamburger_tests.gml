function test_hamburger_top_bun() {
	AssertEqual(CrispyTest.vars.hamburger.ingredients[0].name, "bun", "Expecting 'bun' as hamburger's top ingredient");
}

function test_hamburger_bottom_bun() {
	AssertEqual(CrispyTest.vars.hamburger.ingredients[CrispyTest.vars.hamburger.ingredient_number() - 1].name, "bun", "Expecting 'bun' as hamburger's bottom ingredient");
}

function test_hamburger_number_of_ingredients() {
	var _n = CrispyTest.vars.hamburger.ingredient_number();
	AssertEqual(_n, 6, "hamburger is expected to have only 6 ingredients, not " + string(_n));
}

function test_hamburger_is_not_gluten_free() {
	AssertFalse(CrispyTest.vars.hamburger.is_gluten_free(), "hamburger contains non gluten-free ingredients");
}

function test_hamburger_has_pickles() {
	AssertTrue(CrispyTest.vars.hamburger.has_ingredient("pickles"), "You forgot the pickles!");
}
