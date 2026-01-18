/// @description Saves the result and output of assertion
/// @param {Struct} test_case - Struct that holds the test case
/// @param {Struct} [unpack=undefined] - Struct to use with crispy_struct_unpack
function CrispyLog(_test_case, _unpack = undefined) constructor
{
	if (!__crispy_validate_struct_param(instanceof(self), "", "_test_case", _test_case)) return;

	__struct_unpack = method(self, __crispy_struct_unpack);

	/// @ignore
	__verbosity = CRISPY_VERBOSITY;
	/// @ignore
	__pass = true;
	/// @ignore
	__msg = undefined;
	/// @ignore
	__helper_text = undefined;
	/// @ignore
	__class = _test_case.__class;
	/// @ignore
	__name = _test_case.__name;
	/// @ignore
	__display_name = undefined;

	// Create the display name of log based on CrispyCase name and class
	var _display_name = "";
	if (!is_undefined(__name))
	{
		_display_name += __name;
	}
	
	if (!is_undefined(__class))
	{
		_display_name += (_display_name != "" ? "." + __class : __class);
	}

	/// @ignore
	__display_name = _display_name;

	/// Run struct unpacker if unpack argument was provided
	/// Stays after all variables are initialized so they may be overwritten
	__crispy_validate_unpack_param(instanceof(self), "", _unpack);

	#region METHODS

	/// @description Constructs text based on outcome of test assertion and verbosity
	/// @returns {String} Text based on outcome of test assertion and verbosity
	static GetMsg = function()
	{
		var _msg = (__verbosity == 2 && __display_name != "") ? __display_name + " " : "";

		switch (__verbosity)
		{
			case 0:
				_msg += __pass ? CRISPY_PASS_MSG_SILENT : CRISPY_FAIL_MSG_SILENT;
			break;

			case 1: // Think of something better for this later
			case 2:
				if (__pass)
				{
					_msg += "..." + CRISPY_PASS_MSG_VERBOSE;
				}
				else
				{
					if (!is_undefined(__msg) && __msg != "")
					{
						_msg += "- " + __msg;
					}
					else if (!is_undefined(__helper_text))
					{
						_msg += "- " + __helper_text;
					}
				}
			break;
		}

		return _msg;
	}

	/// @returns {String}
	static toString = function()
	{
		return $"<Crispy Log ({(__pass ? "pass" : "fail")})>";
	}

	#endregion
}