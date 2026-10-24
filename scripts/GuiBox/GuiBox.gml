/// @desc Rectangle in the GUI layer used by the demo object to lay out the report.
/// @param {Real} x1 Left edge of the box.
/// @param {Real} y1 Top edge of the box.
/// @param {Real} x2 Right edge of the box.
/// @param {Real} y2 Bottom edge of the box.
function GuiBox(_x1, _y1, _x2, _y2) constructor
{
	#region PRIVATE

		#region FIELDS

		/// @ignore
		/// @type {Real}
		/// @desc Left edge of the box.
		__x1 = _x1;

		/// @ignore
		/// @type {Real}
		/// @desc Top edge of the box.
		__y1 = _y1;

		/// @ignore
		/// @type {Real}
		/// @desc Right edge of the box.
		__x2 = _x2;

		/// @ignore
		/// @type {Real}
		/// @desc Bottom edge of the box.
		__y2 = _y2;

		#endregion

	#endregion

	#region PUBLIC

		#region METHODS

		/// @desc Draws the rectangle with the given color.
		/// @param {Real} color Color used to draw the rectangle.
		/// @param {Bool} [outline=false] Whether the rectangle is outlined instead of filled.
		/// @return {Struct.GuiBox} this instance
		static Draw = function(_color, _outline = false)
		{
			var _previous_color = draw_get_color();

			draw_set_color(_color);
			draw_rectangle(__x1, __y1, __x2, __y2, _outline);
			draw_set_color(_previous_color);

			return self;
		}

		/// @desc Sets the left edge of the box.
		/// @param {Real} x1 Left edge of the box.
		/// @return {Struct.GuiBox} this instance
		static SetX1 = function(_x1)
		{
			if (!is_real(_x1) )
			{
				__crispy_error($"GuiBox.SetX1() 'x1' expected a real number, received {typeof(_x1)}.");
				return self;
			}

			__x1 = _x1;

			return self;
		}

		/// @desc Sets the top edge of the box.
		/// @param {Real} y1 Top edge of the box.
		/// @return {Struct.GuiBox} this instance
		static SetY1 = function(_y1)
		{
			if (!is_real(_y1) )
			{
				__crispy_error($"GuiBox.SetY1() 'y1' expected a real number, received {typeof(_y1)}.");
				return self;
			}

			__y1 = _y1;

			return self;
		}

		/// @desc Sets the right edge of the box.
		/// @param {Real} x2 Right edge of the box.
		/// @return {Struct.GuiBox} this instance
		static SetX2 = function(_x2)
		{
			if (!is_real(_x2) )
			{
				__crispy_error($"GuiBox.SetX2() 'x2' expected a real number, received {typeof(_x2)}.");
				return self;
			}

			__x2 = _x2;

			return self;
		}

		/// @desc Sets the bottom edge of the box.
		/// @param {Real} y2 Bottom edge of the box.
		/// @return {Struct.GuiBox} this instance
		static SetY2 = function(_y2)
		{
			if (!is_real(_y2) )
			{
				__crispy_error($"GuiBox.SetY2() 'y2' expected a real number, received {typeof(_y2)}.");
				return self;
			}

			__y2 = _y2;

			return self;
		}

		#endregion

		#region GETTERS

		/// @desc Gets the width of the box.
		/// @return {Real} Width of the box.
		static GetWidth = function()
		{
			return abs(__x1 - __x2);
		}

		/// @desc Gets the height of the box.
		/// @return {Real} Height of the box.
		static GetHeight = function()
		{
			return abs(__y1 - __y2);
		}

		/// @desc Gets the left edge of the box.
		/// @return {Real} Left edge of the box.
		static GetX1 = function()
		{
			return __x1;
		}

		/// @desc Gets the top edge of the box.
		/// @return {Real} Top edge of the box.
		static GetY1 = function()
		{
			return __y1;
		}

		/// @desc Gets the right edge of the box.
		/// @return {Real} Right edge of the box.
		static GetX2 = function()
		{
			return __x2;
		}

		/// @desc Gets the bottom edge of the box.
		/// @return {Real} Bottom edge of the box.
		static GetY2 = function()
		{
			return __y2;
		}

		#endregion

	#endregion
}
