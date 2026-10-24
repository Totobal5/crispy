/// @desc Records the result and the output of an assertion.
/// @param {Struct.CrispyCase|Struct.CrispyCaseAsync} test_case Test case that owns the log.
/// @param {Struct} [options=undefined] Optional values that override the log defaults.
function CrispyLog(_test_case, _options = undefined) constructor
{
	#region PRIVATE

		#region FIELDS

		/// @ignore
		/// @type {Real}
		/// @desc Verbosity level of the log.
		__verbosity = CRISPY_VERBOSITY;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether the assertion passed or failed.
		__pass = true;

		/// @ignore
		/// @type {String|Undefined}
		/// @desc Message to display in the log.
		__msg = undefined;

		/// @ignore
		/// @type {String|Undefined}
		/// @desc Helper text to display in the log.
		__helper_text = undefined;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether the test was skipped.
		__skipped = false;

		/// @ignore
		/// @type {String}
		/// @desc Class name of the test case.
		__class = _test_case.__class;

		/// @ignore
		/// @type {String}
		/// @desc Name of the test case.
		__name = _test_case.__name;

		/// @ignore
		/// @type {Real}
		/// @desc Duration of the test case in seconds.
		__duration = 0;

		/// @ignore
		/// @type {String}
		/// @desc Display name built from the test case name and class.
		__display_name = "";

		#endregion

		#region METHODS

		/// @ignore
		/// @desc Formats the test duration with the unit that fits its magnitude.
		/// @return {String} Formatted duration, or an empty string when the duration is negative.
		static __FormatDuration = function()
		{
			if (__duration < 0) return "";

			if (__duration < 0.001) return string_format(__duration * 1000000, 0, 2) + "us";
			if (__duration < 1) return string_format(__duration * 1000, 0, 2) + "ms";

			return string_format(__duration, 0, 2) + "s";
		}

		/// @ignore
		/// @desc Builds the failure text from the assertion message and the helper text.
		/// @return {String} Failure text of the assertion.
		static __FailureText = function()
		{
			var _has_msg = !is_undefined(__msg) && __msg != "";
			var _has_helper_text = !is_undefined(__helper_text) && __helper_text != "";

			if (_has_msg)
			{
				return _has_helper_text ? __msg + "\n" + __helper_text : __msg;
			}

			if (_has_helper_text) return __helper_text;

			return "Assertion failed.";
		}

		#endregion

	#endregion

	// Build the display name from the case name and class.
	var _display_name = "";
	if (!is_undefined(__name) ) { _display_name += __name; }
	if (!is_undefined(__class) ) { _display_name += (_display_name != "" ? "." + __class : __class); }

	__display_name = _display_name;

	// Apply the fields supplied by the assertion or the runner.
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

	#region PUBLIC

		#region METHODS

		/// @desc Builds the log text from the outcome of the assertion and the verbosity level.
		/// @return {String} Text based on the outcome of the assertion and the verbosity.
		static GetMsg = function()
		{
			var _msg = (__verbosity == 2 && __display_name != "") ? __display_name + " " : "";

			switch (__verbosity)
			{
				case 0:
					_msg = (__skipped) ? "S" : (__pass ? CRISPY_PASS_MSG_SILENT : CRISPY_FAIL_MSG_SILENT);
				break;

				case 1:
				case 2:
					if (__skipped)
					{
						_msg += "...skipped";
					}
					else if (__pass)
					{
						_msg += "..." + CRISPY_PASS_MSG_VERBOSE;

						var _duration_str = __FormatDuration();
						if (_duration_str != "") _msg += " (" + _duration_str + ")";
					}
					else
					{
						_msg += "- " + __FailureText();
					}
				break;
			}

			return _msg;
		}

		/// @desc Converts the log into a short debug representation.
		/// @return {String} Debug representation of the log.
		static toString = function()
		{
			return $"<Crispy Log ({(__pass ? "pass" : "fail")})>";
		}

		#endregion

	#endregion
}
