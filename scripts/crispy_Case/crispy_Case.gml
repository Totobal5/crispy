// Feather disable all

/// Creates a Test case object to run assertions
/// @param {String} name - Name of case
/// @param {Function} func - Function for test assertion
/// @param {Struct} [unpack=undefined] - Struct for struct_unpack
function CrispyCase(_name, _func, _unpack = undefined) : CrispyTest(_name) constructor
{
	if (!is_method(_func))
	{
		__crispy_error($"{instanceof(self)} \"func\" expected a function, received {typeof(_func)}.");
	}

	__class = instanceof(self);
	__parent = undefined;
	__test = method(self, _func);
	__logs = [];
	__is_discovered = false;
	__discovered_script = undefined;

	/// Run struct unpacker if unpack argument was provided
	/// Stays after all variables are initialized so they may be overwritten
	if (!is_undefined(_unpack))
	{
		if (is_struct(_unpack))
		{
			struct_unpack(_unpack);
		}
		else
		{
			__crispy_error($"{instanceof(self)} \"unpack\" expected a struct or undefined, recieved {typeof(_unpack)}.");
		}
	}

	// Getters

	/// Get the class name of this test case
	/// @returns {String} Class name of the test case
	static GetClass = function()
	{
		return __class;
	}

	/// Get all logs of this test case
	/// @returns {Array} Array of logs
	static GetLogs = function()
	{
		return __logs;
	}

	// Methods

	/// Adds a Log to the array of logs
	/// @param {Struct} log - Log struct
	static AddLog = function(_log)
	{
		if (!is_struct(_log))
		{
			__crispy_error($"{instanceof(self)}.AddLog() \"log\" expected a struct, recieved {typeof(_log)}.");
		}
		array_push(__logs, _log);
	}

	/// Clears array of Logs
	static ClearLogs = function()
	{
		__logs = [];
	}

	/// Test that first and second are equal
	/// The first and second will be checked for the same type first, then check if they're equal
	/// @param {Any} first - First value
	/// @param {Any} second - Second value to check against first
	/// @param {String} [message] - Custom message to output on failure
	static AssertEqual = function(_first, _second, _message)
	{
		// Check supplied arguments
		if (argument_count < 2)
		{
			show_error($"{instanceof(self)}.AssertEqual() expected 2 arguments, recieved {argument_count}.", true);
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertEqual() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		// Check types of first and second
		if (typeof(_first) != typeof(_second))
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: $"Supplied value types are not equal: {typeof(_first)} and {typeof(_second)}.",
			}));
			return;
		}
		if (_first == _second)
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: $"first and second are not equal: {_first}, {_second}",
			}));
		}
	}

	/// Test that first and second are not equal
	/// @param {Any} first - First type to check
	/// @param {Any} second - Second type to check against
	/// @param {String} [message] - Custom message to output on failure
	static AssertNotEqual = function(_first, _second, _message)
	{
		// Check supplied arguments
		if (argument_count < 2)
		{
			show_error($"{instanceof(self)}.AssertNotEqual() expected 2 arguments, received {argument_count}.", true);
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertNotEqual() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		var _outcome = (typeof(_first) != typeof(_second));
		if (!_outcome)
		{
			_outcome = (_first != _second);
		}
		if (_outcome)
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: $"first and second are equal: {_first}, {_second}",
			}));
		}
	}

	/// Test whether the provided expression is true
	/// The test will first try to convert the expression to a boolean, then check if it equals true
	/// @param {Any} expr - Expression to check
	/// @param {String} [message] - Custom message to output on failure
	static AssertTrue = function(_expr, _message)
	{
		// Check supplied arguments
		if (argument_count < 1)
		{
			show_error($"{instanceof(self)}.AssertTrue() expected 1 argument, received {argument_count}.", true);
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertTrue() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}

		try
		{
			bool(_expr);
		}
		catch (err)
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				helper_text: $"Unable to convert {typeof(_expr)} into boolean. Cannot evaluate.",
			}));
			return;
		}
		if (_expr)
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: "Expression is not true.",
			}));
		}
	}

	/// Test whether the provided expression is false
	/// The test will first try to convert the expression to a boolean, then check if it equals false
	/// @param {Any} expr - Expression to check
	/// @param {String} [message] - Custom message to output on failure
	static AssertFalse = function(_expr, _message)
	{
		// Check supplied arguments
		if (argument_count < 1)
		{
			show_error($"{instanceof(self)}.AssertFalse() expected 1 argument, received {argument_count}.", true);
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertFalse() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}

		try
		{
			bool(_expr);
		}
		catch (err)
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				helper_text: $"Unable to convert {typeof(_expr)} into boolean. Cannot evaluate.",
			}));
			return;
		}
		if (!_expr)
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: "Expression is not false.",
			}));
		}
	}

	/// Test whether the provided expression is noone
	/// @param {Any} expr - Expression to check
	/// @param {String} [message] - Custom message to output on failure
	static AssertIsNoone = function(_expr, _message)
	{
		// Check supplied arguments
		if (argument_count < 1)
		{
			show_error($"{instanceof(self)}.AssertIsNoone() expected 1 argument, received {argument_count}.", true);
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertIsNoone() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		if (_expr == noone)
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: "Expression is not noone.",
			}));
		}
	}

	/// Test whether the provided expression is not noone
	/// @param {Any} expr - Expression to check
	/// @param {String} [message] - Custom message to output on failure
	static AssertIsNotNoone = function(_expr, _message)
	{
		// Check supplied arguments
		if (argument_count < 1)
		{
			show_error($"{instanceof(self)}.AssertIsNotNoone() expected 1 argument, received {argument_count}.", true);
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertIsNotNoone() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		if (_expr != noone)
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: "Expression is noone.",
			}));
		}
	}

	/// Test whether the provided expression is undefined
	/// @param {Any} expr - Expression to check
	/// @param {String} [message] - Custom message to output on failure
	static AssertIsUndefined = function(_expr, _message)
	{
		// Check supplied arguments
		if (argument_count < 1)
		{
			show_error($"{instanceof(self)}.AssertIsUndefined() expected 1 argument, received {argument_count}.", true);
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertIsUndefined() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		if (is_undefined(_expr))
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: "Expression is not undefined.",
			}));
		}
	}

	/// Test whether the provided expression is not undefined
	/// @param {Any} expr - Expression to check
	/// @param {String} [message] - Custom message to output on failure
	static AssertIsNotUndefined = function(_expr, _message)
	{
		// Check supplied arguments
		if (argument_count < 1)
		{
			show_error($"{instanceof(self)}.AssertIsNotUndefined() expected 1 argument, received {argument_count}.", true);
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertIsNotUndefined() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		if (!is_undefined(_expr))
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: "Expression is undefined.",
			}));
		}
	}

	/// Test whether the provided function will throw an error message
	/// @param {Function} func - Function to check whether it throws an error message
	/// @param {String} [message] - Custom message to output on failure
	static AssertRaises = function(_func, _message)
	{
		// Check supplied arguments
		if (argument_count < 1)
		{
			show_error($"{instanceof(self)}.AssertRaises() expected 1 argument, received {argument_count}.", true);
		}
		if (!is_method(_func))
		{
			__crispy_error($"{instanceof(self)}.AssertRaises() \"func\" expected a function, received {typeof(_func)}.");
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertRaises() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		try
		{
			_func();
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: "Error message was not thrown.",
			}));
		}
		catch (err)
		{
			AddLog(new CrispyLog(self, {
				pass: true,
			}));
		}
	}

	/// Test the value of the error message thrown in the provided function
	/// @param {Function} func - Function ran to throw an error message
	/// @param {String} value - Value of error message to check
	/// @param {String} [message] - Custom message to output on failure
	static AssertRaiseErrorValue = function(_func, _value, _message)
	{
		// Check supplied arguments
		if (argument_count < 2)
		{
			show_error($"{instanceof(self)}.AssertRaiseErrorValue() expected 2 arguments, received {argument_count}.", true);
		}
		if (!is_method(_func))
		{
			__crispy_error($"{instanceof(self)}.AssertRaiseErrorValue() \"func\" expected a function, received {typeof(_func)}.");
		}
		if (!is_string(_value))
		{
			__crispy_error($"{instanceof(self)}.AssertRaiseErrorValue() \"value\" expected a string, received {typeof(_value)}.");
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertRaiseErrorValue() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		try
		{
			_func();
			AddLog(new CrispyLog(self, {
				pass: false,
				helper_text: "Error message was not thrown.",
			}));
		}
		catch (err)
		{
			// If the error message was thrown using show_error, use the
			// message value from the exception struct for the assertion
			if (is_struct(err) && variable_struct_exists(err, "message") && is_string(err.message))
			{
				err = err.message;
			}
			if (err == _value)
			{
				AddLog(new CrispyLog(self, {
					pass: true,
				}));
			}
			else
			{
				AddLog(new CrispyLog(self, {
					pass: false,
					msg: _message,
					helper_text: $"Error message is not equal to value: \"{err}\" != \"{_value}\"",
				}));
			}
		}
	}

	/// Test whether the provided function runs without throwing an error
	/// @param {Function} func - Function to check whether it executes safely
	/// @param {String} [message] - Custom message to output on failure
	static AssertDoesNotThrow = function(_func, _message)
	{
		// Check supplied arguments
		if (argument_count < 1)
		{
			show_error($"{instanceof(self)}.AssertDoesNotThrow() expected 1 argument, received {argument_count}.", true);
		}
		if (!is_method(_func))
		{
			__crispy_error($"{instanceof(self)}.AssertDoesNotThrow() \"func\" expected a function, received {typeof(_func)}.");
		}
		if (!is_string(_message) && !is_undefined(_message))
		{
			__crispy_error($"{instanceof(self)}.AssertDoesNotThrow() \"message\" expected either a string or undefined, received {typeof(_message)}.");
		}
		try
		{
			_func();
			AddLog(new CrispyLog(self, {
				pass: true,
				msg: _message,
			}));
		}
		catch (err)
		{
			AddLog(new CrispyLog(self, {
				pass: false,
				msg: _message,
				helper_text: $"An unexpected error was thrown: {err}",
			}));
		}
	}

	/// Function ran before test, used to set up test
	/// @param {Function} [func] - Method to override __SetUp__ with
	static SetUp = function()
	{
		if (argument_count > 0)
		{
			var _func = argument[0];
			if (is_method(_func))
			{
				__SetUp__ = method(self, _func);
			}
			else
			{
				__crispy_error($"{instanceof(self)}.SetUp() \"func\" expected a function, received {typeof(_func)}.");
			}
		}
		else
		{
			ClearLogs();
			if (is_method(__SetUp__))
			{
				__SetUp__();
			}
		}
	}

	/// Function ran after test, used to clean up test
	/// @param {Function} [func] - Method to override __TearDown__ with
	static TearDown = function()
	{
		if (argument_count > 0)
		{
			var _func = argument[0];
			if (is_method(_func))
			{
				__TearDown__ = method(self, _func);
			}
			else
			{
				__crispy_error($"{instanceof(self)}.TearDown() \"func\" expected a function, received {typeof(_func)}.");
			}
		}
		else
		{
			if (is_method(__TearDown__))
			{
				__TearDown__();
			}
		}
	}

	/// Set of functions to run in order for the test
	static Run = function()
	{
		SetUp();
		onRunBegin();
		__test();
		onRunEnd();
		TearDown();
	}

	/// Sets up a discovered script to use as the test
	/// @param {Real} script - Index ID of script
	/// @ignore
	static __Discover = function(_script)
	{
		if (!is_real(_script))
		{
			__crispy_error($"{instanceof(self)}.__Discover() \"script\" expected a real number, received {typeof(_script)}.");
		}
		if (!script_exists(_script))
		{
			__crispy_error($"{instanceof(self)}.__Discover() asset of index {_script} is not a script function.");
		}
		__discovered_script = _script;
		__is_discovered = true;
		__test = method(self, _script);
	}

	/// @returns {String}
	static toString = function()
	{
		return $"<Crispy TestCase(\"{__name}\")>";
	}

}
