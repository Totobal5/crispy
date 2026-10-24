/// @desc Verifies the GuiBox sample constructor.

function test_gui_box_position_x1()
{
	var _box = new GuiBox(10, 20, 30, 40);

	AssertEqual(_box.GetX1(), 10, "Box should keep its left edge");
}

function test_gui_box_position_y1()
{
	var _box = new GuiBox(10, 20, 30, 40);

	AssertEqual(_box.GetY1(), 20, "Box should keep its top edge");
}

function test_gui_box_position_x2()
{
	var _box = new GuiBox(10, 20, 30, 40);

	AssertEqual(_box.GetX2(), 30, "Box should keep its right edge");
}

function test_gui_box_position_y2()
{
	var _box = new GuiBox(10, 20, 30, 40);

	AssertEqual(_box.GetY2(), 40, "Box should keep its bottom edge");
}

function test_gui_box_width()
{
	var _box = new GuiBox(10, 10, 20, 20);

	AssertEqual(_box.GetWidth(), 10, "Box width should be the distance between its edges");
}

function test_gui_box_height()
{
	var _box = new GuiBox(10, 10, 25, 25);

	AssertEqual(_box.GetHeight(), 15, "Box height should be the distance between its edges");
}

function test_gui_box_get_x1()
{
	var _box = new GuiBox(10, 10, 20, 20);

	AssertEqual(_box.GetX1(), 10, "GetX1 should return the left edge");
}

function test_gui_box_get_y1()
{
	var _box = new GuiBox(10, 10, 20, 20);

	AssertEqual(_box.GetY1(), 10, "GetY1 should return the top edge");
}

function test_gui_box_get_x2()
{
	var _box = new GuiBox(10, 10, 20, 20);

	AssertEqual(_box.GetX2(), 20, "GetX2 should return the right edge");
}

function test_gui_box_get_y2()
{
	var _box = new GuiBox(10, 10, 20, 20);

	AssertEqual(_box.GetY2(), 20, "GetY2 should return the bottom edge");
}

function test_gui_box_set_x1()
{
	var _box = new GuiBox(10, 10, 20, 20);

	_box.SetX1(15);

	AssertEqual(_box.GetX1(), 15, "SetX1 should update the left edge");
}

function test_gui_box_set_y1()
{
	var _box = new GuiBox(10, 10, 20, 20);

	_box.SetY1(15);

	AssertEqual(_box.GetY1(), 15, "SetY1 should update the top edge");
}

function test_gui_box_set_x2()
{
	var _box = new GuiBox(10, 10, 20, 20);

	_box.SetX2(15);

	AssertEqual(_box.GetX2(), 15, "SetX2 should update the right edge");
}

function test_gui_box_set_y2()
{
	var _box = new GuiBox(10, 10, 20, 20);

	_box.SetY2(15);

	AssertEqual(_box.GetY2(), 15, "SetY2 should update the bottom edge");
}
