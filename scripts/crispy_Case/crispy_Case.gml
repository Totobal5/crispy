/// @desc Creates a test case that runs assertions.
/// @param {String} name Name of case
/// @param {Function} callback Callback that executes the test assertions
function CrispyCase(_name, _func) : CrispyTest(_name) constructor
{
	if (!is_callable(_func) )
	{
		__crispy_error($"CrispyCase 'callback' expected a callable value, received {typeof(_func)}.");
	}

	/// @ignore
	/// @desc Constructor name for this test case.
	/// @type {String}
	__class = instanceof(self);

	/// @ignore
	/// @desc Suite that owns this case.
	/// @type {Struct.CrispySuite|Undefined}
	__parent = undefined;

	/// @ignore
	/// @desc Bound function that executes the test.
	/// @type {Function}
	__test = method(self, _func);

	/// @ignore
	/// @desc Assertion logs recorded during the last run.
	/// @type {Array<Struct.CrispyLog>}
	__logs = [];

	/// @ignore
	/// @desc Duration of the last run in seconds.
	/// @type {Real}
	__duration = 0;

	/// @ignore
	/// @desc Whether this case was created through discovery.
	/// @type {Bool}
	__is_discovered = false;

	/// @ignore
	/// @desc Script asset used to create this discovered case.
	/// @type {Real|Undefined}
	__discovered_script = undefined;

	/// @ignore
	/// @desc Whether this case is skipped during execution.
	/// @type {Bool}
	__skipped = false;
	
	// Getters

	/// @desc Get the class name of this test case
	/// @returns {String} Class name of the test case
	static GetClass = function()
	{
		return __class;
	}

	/// @desc Get all logs of this test case
	/// @returns {Array} Array of logs
	static GetLogs = function()
	{
		return __logs;
	}

	/// @desc Get the duration of the last run in seconds
	/// @returns {Real} Duration in seconds
	static GetDuration = function()
	{
		return __duration;
	}

	/// @desc Check if this test case is skipped
	/// @returns {Bool} Whether the test is skipped
	static IsSkipped = function()
	{
		return __skipped;
	}

	// Methods

	/// @desc Adds a Log to the array of logs
	/// @param {Struct} log - Log struct
	/// @returns {Struct.CrispyCase} Self for chaining
	static AddLog = function(_log)
	{
		array_push(__logs, _log);

		return self;
	}

	/// @desc Clears array of Logs
	/// @returns {Struct.CrispyCase} Self for chaining
	static ClearLogs = function()
	{
		__logs = [];
		return self;
	}

	/// @desc Mark this test case as skipped
	/// @returns {Struct.CrispyCase} Self for chaining
	static Skip = function()
	{
		__skipped = true;
		return self;
	}

	/// @desc Test that a value is contained in array or string
	/// @param {Any} container Array or string to search in
	/// @param {Any} value Value to find
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertContains = function(_container, _value, _message)
	{
		var _found = false;

		if (is_array(_container))
		{
			var _i = 0; repeat (array_length(_container))
			{
				if (_container[_i] == _value)
				{
					_found = true;
					break;
				}
				++_i;
			}
		}
		else if (is_string(_container) )
		{
			_found = (string_pos(_value, _container) > 0);
		}
		else
		{
			__crispy_error($"CrispyCase.AssertContains() 'container' expected an array or string, received {typeof(_container)}.");
			return self;
		}

		if (_found)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: $"value not found in container: {_value}",
			}));
		}

		return self;
	}

	/// @desc Test that two numbers are approximately equal within a tolerance
	/// @param {Real} actual Actual value
	/// @param {Real} expected Expected value
	/// @param {Real} tolerance Maximum allowed difference
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertNear = function(_actual, _expected, _tolerance, _message)
	{
		var _diff = abs(_actual - _expected);

		if (_diff <= _tolerance)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: $"values differ by {_diff}, tolerance is {_tolerance}: {_actual} vs {_expected}",
			}));
		}

		return self;
	}

	/// @desc Test that two values are equal
	/// @param {Any} first First value
	/// @param {Any} second Second value to check against first
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertEqual = function(_first, _second, _message)
	{
		// Check types of first and second
		if (typeof(_first) != typeof(_second) )
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
                __msg: _message,
				__helper_text: $"Supplied value types are not equal: {typeof(_first)} and {typeof(_second)}.",
			}));

			return self;
		}

		if (_first == _second)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: $"first and second are not equal: {_first}, {_second}",
			}));
		}

		return self;
	}

	/// @desc Test deep equality between two values (arrays/structs recurse)
	/// @param {Any} first First value
	/// @param {Any} second Second value to check against first
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertDeepEqual = function(_first, _second, _message)
	{
		if (__DeepEqual(_first, _second))
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: "first and second are not deeply equal.",
			}));
		}

		return self;
	}

	/// @desc Test that first and second are not equal
	/// @param {Any} first First type to check
	/// @param {Any} second Second type to check against
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertNotEqual = function(_first, _second, _message)
	{
		var _outcome = (typeof(_first) != typeof(_second) );
		if (!_outcome) { _outcome = (_first != _second); }

		if (_outcome)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: $"first and second are equal: {_first}, {_second}",
			}));
		}

		return self;
	}

	/// @desc Test whether the provided expression is true.
	/// @param {Any} expr Expression to check
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertTrue = function(_expr, _message)
	{
		var _true = false;
		try { _true = bool(_expr); }
		catch (err)
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__helper_text: $"Unable to convert {typeof(_expr)} into boolean. Cannot evaluate.",
			}));
			
			return self;
		}

		if (_true)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}) );
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass:	false,
				__msg:	_message,
				__helper_text: "Expression is not true.",
			}));
		}
		
		return self;
	}

	/// @desc Test whether the provided expression is false.
	/// @param {Any} expr Expression to check
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertFalse = function(_expr, _message)
	{
		var _false = false;
		try { _false = bool(_expr); }
		catch (err)
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__helper_text: $"Unable to convert {typeof(_expr)} into boolean. Cannot evaluate.",
			}) );

			return self;
		}
		
		if (!_false)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}) );
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: "Expression is not false.",
			}) );
		}
		
		return self;
	}

	/// @desc Test whether the provided expression is noone.
	/// @param {Any} expr Expression to check
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertIsNoone = function(_expr, _message)
	{
		if (_expr == noone)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: "Expression is not noone.",
			}));
		}

		return self;
	}

	/// @desc Test whether the provided expression is not noone.
	/// @param {Any} expr Expression to check
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertIsNotNoone = function(_expr, _message)
	{
		if (_expr != noone)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: "Expression is noone.",
			}));
		}

		return self;
	}

	/// @desc Test whether the provided expression is undefined.
	/// @param {Any} expr Expression to check
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertIsUndefined = function(_expr, _message)
	{
		if (is_undefined(_expr) )
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: "Expression is not undefined.",
			}));
		}

		return self;
	}

	/// @desc Test whether the provided expression is not undefined.
	/// @param {Any} expr Expression to check
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertIsNotUndefined = function(_expr, _message)
	{
		if (!is_undefined(_expr) )
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		else
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: "Expression is undefined.",
			}));
		}

		return self;
	}

	/// @desc Test whether the provided function will throw an error message.
	/// @param {Function} callback Callback to check whether it throws an error message
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertRaises = function(_func, _message)
	{
		if (!is_callable(_func) )
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: $"Expected a callable callback, received {typeof(_func)}.",
			}));

			return self;
		}

		try
		{
			_func();
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: "Error message was not thrown.",
			}));
		}
		catch (err)
		{
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}

		return self;
	}

	/// @desc Test the value of the error message thrown in the provided function.
	/// @param {Function} callback Callback run to throw an error message
	/// @param {String} value Value of error message to check
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertRaiseErrorValue = function(_func, _value, _message)
	{
		if (!is_callable(_func) )
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: $"Expected a callable callback, received {typeof(_func)}.",
			}));

			return self;
		}
		
		try
		{
			_func();
			AddLog(new CrispyLog(self, {
				__pass: false,
				__helper_text: "Error message was not thrown.",
			}));
		}
		catch (err)
		{
			// If the error message was thrown using show_error, use the
			// message value from the exception struct for the assertion
			if (is_struct(err) ) { err = err[$ "message"]; }
			if (err == _value)
			{
				AddLog(new CrispyLog(self, {
					__pass: true,
				}));
			}
			else
			{
				AddLog(new CrispyLog(self, {
					__pass: false,
					__msg: _message,
					__helper_text: $"Error message is not equal to value: \"{err}\" != \"{_value}\"",
				}));
			}
		}

		return self;
	}

	/// @desc Test whether the provided function runs without throwing an error.
	/// @param {Function} callback Callback to check whether it executes safely
	/// @param {String} [message] Custom message to output on failure
	/// @returns {Struct.CrispyCase} Self for chaining
	static AssertDoesNotThrow = function(_func, _message)
	{
		try
		{
			_func();
			AddLog(new CrispyLog(self, {
				__pass: true,
			}));
		}
		catch (err)
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
				__helper_text: $"An unexpected error was thrown: {err}",
			}));
		}

		return self;
	}

	/// @desc Callback run before the test to prepare its state.
	/// @param {Function} [callback] Callback to override __SetUp with
	/// @returns {Struct.CrispyCase} Self for chaining
	static SetUp = function(_func)
	{
		if (!is_undefined(_func))
		{
			__SetUp = method(self, _func);
		}
		else
		{
			ClearLogs();
			if (is_callable(__SetUp) ) { __SetUp(); }
		}

		return self;
	}

	/// @desc Callback run after the test to clean up its state.
	/// @param {Function} [callback] Callback to override __TearDown with
	/// @returns {Struct.CrispyCase} Self for chaining
	static TearDown = function(_func)
	{
		if (!is_undefined(_func) )
		{
			__TearDown = method(self, _func);
		}
		else
		{
			if (is_callable(__TearDown) ) { __TearDown(); }
		}
		
		return self;
	}

	/// @desc Set of functions to run in order for the test
	static Run = function()
	{
		if (__skipped) return self;
		
		var _start_time = get_timer();
		var _error = undefined;

		try
		{
			SetUp();
			OnRunBegin();
			__test();
			OnRunEnd();
		}
		// If an error is thrown during the test, catch it and store it in _error to be handled after teardown.
		catch (err) { _error = err; }
		
		// Run teardown and calculate duration after the test has completed.
		TearDown();
		__duration = (get_timer() - _start_time) / 1000000;

		// If an error was thrown during the test, display it in the Output Window.
		if (!is_undefined(_error) ) 
		{
			__crispy_alert($"CrispyCase.Run() encountered an error during execution: {_error}");
		}
		
		return self;
	}
	
	/// @returns {String}
	static toString = function()
	{
		return $"<Crispy Case(\"{__name}\")>";
	}

	/// @ignore
	/// @desc Sets up a discovered script to use as the test
	/// @param {Real} script Index ID of script
	static __Discover = function(_script)
	{
		if (!is_real(_script))
		{
			__crispy_error($"CrispyCase.__Discover() 'script' expected a real number, received {typeof(_script)}.");
		}

		if (!script_exists(_script))
		{
			__crispy_error($"CrispyCase.__Discover() asset of index {_script} is not a script function.");
		}
		
		__discovered_script = _script;
		__is_discovered = true;
		__test = method(self, _script);
	}

    /// @ignore
	/// @desc Helper function for deep equality check between two values (arrays/structs recurse)
	/// @param {Any} a First value
	/// @param {Any} b Second value to check against first
    static __DeepEqual = function(_a, _b)
	{
		if (typeof(_a) != typeof(_b) ) return false;

		if (is_array(_a) )
		{
			var _a_length = array_length(_a);
			if (_a_length != array_length(_b) ) return false;

			var _i = 0; repeat (_a_length)
			{
				if (!__DeepEqual(_a[_i], _b[_i] ) ) return false;
				++_i;
			}
			
			return true;
		}

		if (is_struct(_a) )
		{
			var _a_keys = struct_get_names(_a);
			var _b_keys = struct_get_names(_b);

			var _a_keys_length = array_length(_a_keys);
			if (_a_keys_length != array_length(_b_keys)) return false;

			array_sort(_a_keys, true);
			array_sort(_b_keys, true);

			var k = 0; repeat (_a_keys_length)
			{
				var _name = _a_keys[k];
				if (_name != _b_keys[k]) return false;
				if (!__DeepEqual(struct_get(_a, _name), struct_get(_b, _name) ) ) return false;
				++k;
			}

			return true;
		}

		return (_a == _b);
	}
}