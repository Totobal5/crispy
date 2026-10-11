/// @desc Saves the result and output of assertion
/// @param {Struct.CrispyCase|Struct.CrispyCaseAsync} test_case Struct that holds the test case
/// @param {Struct} [options=undefined] Optional values that override log defaults.
function CrispyLog(_test_case, _options = undefined) constructor
{
	/// @ignore
	/// @desc Verbosity level of the log
	/// @type {Real}
	__verbosity = CRISPY_VERBOSITY;

	/// @ignore
	/// @desc Whether the test passed or failed
	/// @type {Boolean}
	__pass = true;

	/// @ignore
	/// @desc Message to display in the log
	/// @type {String}
	__msg = undefined;

	/// @ignore
	/// @desc Helper text to display in the log
	/// @type {String}
	__helper_text = undefined;

	/// @ignore
	/// @desc Whether the test was skipped
	/// @type {Boolean}
	__skipped = false;

	/// @ignore
	/// @desc Class name of the test case
	/// @type {String}
	__class = _test_case.__class;

	/// @ignore
	/// @desc Name of the test case
	/// @type {String}
	__name = _test_case.__name;

	/// @ignore
	/// @desc Duration of the test case
	/// @type {Real}
	__duration = 0;

	/// @ignore
	/// @desc Display name of the log based on CrispyCase name and class
	/// @type {String}
	__display_name = undefined;

	// Create the display name of log based on CrispyCase name and class
	var _display_name = "";
	if (!is_undefined(__name) ) { _display_name += __name; }	
	if (!is_undefined(__class) ) { _display_name += (_display_name != "" ? "." + __class : __class); }

	/// @ignore
	/// @desc Display name of the log based on CrispyCase name and class
	/// @type {String}
	__display_name = _display_name;

	// Apply the fields supplied by the assertion or runner.
	if (is_struct(_options) )
	{
		__display_name = _options[$ "__display_name"] ?? __display_name;
		__helper_text = _options[$ "__helper_text"] ?? __helper_text;
		__verbosity = _options[$ "__verbosity"] ?? __verbosity;
		__duration = _options[$ "__duration"] ?? __duration;
		__skipped = _options[$ "__skipped"] ?? __skipped;
		__class = _options[$ "__class"] ?? __class;
		__name = _options[$ "__name"] ?? __name;
		__pass = _options[$ "__pass"] ?? __pass;
		__msg = _options[$ "__msg"] ?? __msg;
	}
	
	#region METHODS

	/// @desc Constructs text based on outcome of test assertion and verbosity
	/// @returns {String} Text based on outcome of test assertion and verbosity
	static GetMsg = function()
	{
		var _msg = (__verbosity == 2 && __display_name != "") ? __display_name + " " : "";

		switch (__verbosity)
		{
			case 0:
				_msg = (__skipped) ? "S" : (__pass ? CRISPY_PASS_MSG_SILENT : CRISPY_FAIL_MSG_SILENT);
			break;
			
			// Think of something better for this later
			case 1:
			case 2:
				if (__skipped)
				{
					_msg += "...skipped";
				}
				else if (__pass)
				{
					_msg += "..." + CRISPY_PASS_MSG_VERBOSE;
					if (__duration >= 0)
					{
						var _duration_str = "";
						if (__duration < 0.001)
						{
							_duration_str = string_format(__duration * 1000000, 0, 2) + "us";
						}
						else if (__duration < 1)
						{
							_duration_str = string_format(__duration * 1000, 0, 2) + "ms";
						}
						else
						{
							_duration_str = string_format(__duration, 0, 2) + "s";
						}
						_msg += " (" + _duration_str + ")";
					}
				}
				else
				{
					var _has_msg = !is_undefined(__msg) && __msg != "";
					var _has_helper_text = !is_undefined(__helper_text) && __helper_text != "";
					
					if (!is_undefined(__msg) && __msg != "")
					{
						_msg += "- " + __msg;
						if (_has_helper_text) _msg += "\n" + __helper_text;
					}
					else if (_has_helper_text)
					{
						_msg += "- " + __helper_text;
					}
					else if (!_has_msg && !_has_helper_text)
					{
						_msg += "- Assertion failed.";
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