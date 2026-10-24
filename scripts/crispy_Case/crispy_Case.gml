/// @desc Creates a test case that runs assertions.
/// @param {String} name Name of the case.
/// @param {Function} callback Callback that executes the test assertions.
function CrispyCase(_name, _func) : CrispyTest(_name) constructor
{
	if (!is_callable(_func) )
	{
		__crispy_error($"CrispyCase 'callback' expected a callable value, received {typeof(_func)}.");
	}

	#region PRIVATE

		#region FIELDS

		/// @ignore
		/// @type {String}
		/// @desc Constructor name of this test case.
		__class = instanceof(self);

		/// @ignore
		/// @type {Struct.CrispySuite|Undefined}
		/// @desc Suite that owns this case.
		__parent = undefined;

		/// @ignore
		/// @type {Function}
		/// @desc Bound function that executes the test.
		__test = method(self, _func);

		/// @ignore
		/// @type {Array<Struct.CrispyLog>}
		/// @desc Assertion logs recorded during the last run.
		__logs = [];

		/// @ignore
		/// @type {Real}
		/// @desc Duration of the last run in seconds.
		__duration = 0;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether this case was created through discovery.
		__is_discovered = false;

		/// @ignore
		/// @type {Real|Undefined}
		/// @desc Script asset used to create this discovered case, or undefined when registered manually.
		__discovered_script = undefined;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether this case is skipped during execution.
		__skipped = false;

		#endregion

		#region METHODS

		/// @ignore
		/// @desc Records the outcome of an assertion.
		/// @param {Bool} pass Whether the assertion passed.
		/// @param {String|Undefined} message Custom message to output on failure.
		/// @param {String|Undefined} helper_text Diagnostic text added on failure.
		/// @return {Struct.CrispyCase} this instance
		static __AddAssertionLog = function(_pass, _message, _helper_text)
		{
			AddLog(new CrispyLog(self, {
				__pass: _pass,
				__msg: _pass ? undefined : _message,
				__helper_text: _pass ? undefined : _helper_text,
			}) );

			return self;
		}

		/// @ignore
		/// @desc Sets up a discovered script to use as the test.
		/// @param {Real} script Index of the script asset.
		/// @return {Struct.CrispyCase} this instance
		static __Discover = function(_script)
		{
			if (!is_real(_script) )
			{
				__crispy_error($"CrispyCase.__Discover() 'script' expected a real number, received {typeof(_script)}.");
				return self;
			}

			if (!script_exists(_script) )
			{
				__crispy_error($"CrispyCase.__Discover() asset of index {_script} is not a script function.");
				return self;
			}

			__discovered_script = _script;
			__is_discovered = true;
			__test = method(self, _script);

			return self;
		}

		/// @ignore
		/// @desc Compares two values recursively, descending into arrays and structs.
		/// @param {Any} a Value to compare.
		/// @param {Any} b Value to compare against.
		/// @return {Bool} Whether both values are deeply equal.
		static __DeepEqual = function(_a, _b)
		{
			if (typeof(_a) != typeof(_b) ) return false;

			if (is_array(_a) )
			{
				var _a_length = array_length(_a);
				if (_a_length != array_length(_b) ) return false;

				var i = 0;
				repeat (_a_length)
				{
					if (!__DeepEqual(_a[i], _b[i]) ) return false;

					++i;
				}

				return true;
			}

			if (is_struct(_a) )
			{
				var _a_keys = struct_get_names(_a);
				var _b_keys = struct_get_names(_b);

				var _a_keys_length = array_length(_a_keys);
				if (_a_keys_length != array_length(_b_keys) ) return false;

				// Sorting both key arrays lets the comparison run in a single pass.
				array_sort(_a_keys, true);
				array_sort(_b_keys, true);

				var j = 0;
				repeat (_a_keys_length)
				{
					var _key = _a_keys[j];
					if (_key != _b_keys[j]) return false;
					if (!__DeepEqual(struct_get(_a, _key), struct_get(_b, _key) ) ) return false;

					++j;
				}

				return true;
			}

			return (_a == _b);
		}

		#endregion

	#endregion

	#region PUBLIC

		#region METHODS

		/// @desc Adds a log to the array of logs.
		/// @param {Struct.CrispyLog} log Log to add.
		/// @return {Struct.CrispyCase} this instance
		static AddLog = function(_log)
		{
			array_push(__logs, _log);

			return self;
		}

		/// @desc Clears the array of logs.
		/// @return {Struct.CrispyCase} this instance
		static ClearLogs = function()
		{
			__logs = [];

			return self;
		}

		/// @desc Marks this test case as skipped.
		/// @return {Struct.CrispyCase} this instance
		static Skip = function()
		{
			__skipped = true;

			return self;
		}

		/// @desc Registers or runs the setup callback, clearing the logs of the previous run first.
		/// @param {Function} [callback=undefined] Callback to run before the test; omit it to run the registered one.
		/// @return {Struct.CrispyCase} this instance
		static SetUp = function(_func = undefined)
		{
			if (!is_undefined(_func) )
			{
				__SetUp = method(self, _func);
			}
			else
			{
				ClearLogs();
				if (is_callable(__SetUp) ) __SetUp();
			}

			return self;
		}

		/// @desc Registers or runs the teardown callback.
		/// @param {Function} [callback=undefined] Callback to run after the test; omit it to run the registered one.
		/// @return {Struct.CrispyCase} this instance
		static TearDown = function(_func = undefined)
		{
			if (!is_undefined(_func) )
			{
				__TearDown = method(self, _func);
			}
			else
			{
				if (is_callable(__TearDown) ) __TearDown();
			}

			return self;
		}

		/// @desc Runs the case lifecycle: setup, body, and teardown.
		/// @return {Struct.CrispyCase} this instance
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
			// Store the error so the teardown still runs before it is reported.
			catch (err)
			{
				_error = err;
			}

			TearDown();
			__duration = (get_timer() - _start_time) / 1000000;

			if (!is_undefined(_error) )
			{
				__crispy_alert($"CrispyCase.Run() encountered an error during execution: {_error}");
			}

			return self;
		}

		/// @desc Converts the case into a short debug representation.
		/// @return {String} Debug representation of the case.
		static toString = function()
		{
			return $"<Crispy Case(\"{__name}\")>";
		}

		#endregion

		#region ASSERTIONS

		/// @desc Tests that a value is contained in an array or a string.
		/// @param {Any} container Array or string to search in.
		/// @param {Any} value Value to find.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertContains = function(_container, _value, _message)
		{
			if (!is_array(_container) && !is_string(_container) )
			{
				__crispy_error(
					$"CrispyCase.AssertContains() 'container' expected an array or a string, "
					+ $"received {typeof(_container)}."
				);
				return self;
			}

			if (is_string(_container) && !is_string(_value) )
			{
				__crispy_error(
					$"CrispyCase.AssertContains() 'value' expected a string when the container is a string, "
					+ $"received {typeof(_value)}."
				);
				return self;
			}

			var _found = false;

			if (is_array(_container) )
			{
				var i = 0;
				repeat (array_length(_container) )
				{
					if (_container[i] == _value)
					{
						_found = true;
						break;
					}

					++i;
				}
			}
			else
			{
				_found = (string_pos(_value, _container) > 0);
			}

			return __AddAssertionLog(_found, _message, $"value not found in container: {_value}");
		}

		/// @desc Tests that two numbers are approximately equal within a tolerance.
		/// @param {Real} actual Actual value.
		/// @param {Real} expected Expected value.
		/// @param {Real} tolerance Maximum allowed difference.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertNear = function(_actual, _expected, _tolerance, _message)
		{
			if (!is_real(_actual) || !is_real(_expected) || !is_real(_tolerance) )
			{
				var _types = $"{typeof(_actual)}, {typeof(_expected)}, and {typeof(_tolerance)}";
				__crispy_error($"CrispyCase.AssertNear() expected real numbers, received {_types}.");
				return self;
			}

			var _diff = abs(_actual - _expected);

			return __AddAssertionLog(
				_diff <= _tolerance,
				_message,
				$"values differ by {_diff}, tolerance is {_tolerance}: {_actual} vs {_expected}"
			);
		}

		/// @desc Tests that two values are equal.
		/// @param {Any} first First value.
		/// @param {Any} second Second value to check against the first.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertEqual = function(_first, _second, _message)
		{
			if (typeof(_first) != typeof(_second) )
			{
				return __AddAssertionLog(
					false,
					_message,
					$"Supplied value types are not equal: {typeof(_first)} and {typeof(_second)}."
				);
			}

			return __AddAssertionLog(_first == _second, _message, $"first and second are not equal: {_first}, {_second}");
		}

		/// @desc Tests deep equality between two values, recursing through arrays and structs.
		/// @param {Any} first First value.
		/// @param {Any} second Second value to check against the first.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertDeepEqual = function(_first, _second, _message)
		{
			return __AddAssertionLog(__DeepEqual(_first, _second), _message, "first and second are not deeply equal.");
		}

		/// @desc Tests that two values are not equal.
		/// @param {Any} first First value.
		/// @param {Any} second Second value to check against the first.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertNotEqual = function(_first, _second, _message)
		{
			var _different = (typeof(_first) != typeof(_second) );
			if (!_different) _different = (_first != _second);

			return __AddAssertionLog(_different, _message, $"first and second are equal: {_first}, {_second}");
		}

		/// @desc Tests that the provided expression is true.
		/// @param {Any} expr Expression to check.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertTrue = function(_expr, _message)
		{
			var _true = false;

			try
			{
				_true = bool(_expr);
			}
			catch (err)
			{
				return __AddAssertionLog(false, undefined, $"Unable to convert {typeof(_expr)} into boolean. Cannot evaluate.");
			}

			return __AddAssertionLog(_true, _message, "Expression is not true.");
		}

		/// @desc Tests that the provided expression is false.
		/// @param {Any} expr Expression to check.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertFalse = function(_expr, _message)
		{
			var _true = false;

			try
			{
				_true = bool(_expr);
			}
			catch (err)
			{
				return __AddAssertionLog(false, undefined, $"Unable to convert {typeof(_expr)} into boolean. Cannot evaluate.");
			}

			return __AddAssertionLog(!_true, _message, "Expression is not false.");
		}

		/// @desc Tests that the provided expression is noone.
		/// @param {Any} expr Expression to check.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertIsNoone = function(_expr, _message)
		{
			return __AddAssertionLog(_expr == noone, _message, "Expression is not noone.");
		}

		/// @desc Tests that the provided expression is not noone.
		/// @param {Any} expr Expression to check.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertIsNotNoone = function(_expr, _message)
		{
			return __AddAssertionLog(_expr != noone, _message, "Expression is noone.");
		}

		/// @desc Tests that the provided expression is undefined.
		/// @param {Any} expr Expression to check.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertIsUndefined = function(_expr, _message)
		{
			return __AddAssertionLog(is_undefined(_expr), _message, "Expression is not undefined.");
		}

		/// @desc Tests that the provided expression is not undefined.
		/// @param {Any} expr Expression to check.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertIsNotUndefined = function(_expr, _message)
		{
			return __AddAssertionLog(!is_undefined(_expr), _message, "Expression is undefined.");
		}

		/// @desc Tests that the provided callback throws.
		/// @param {Function} callback Callback expected to throw.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertRaises = function(_func, _message)
		{
			if (!is_callable(_func) )
			{
				return __AddAssertionLog(false, _message, $"Expected a callable callback, received {typeof(_func)}.");
			}

			try
			{
				_func();
			}
			catch (err)
			{
				return __AddAssertionLog(true, undefined, undefined);
			}

			return __AddAssertionLog(false, _message, "Error message was not thrown.");
		}

		/// @desc Tests the value of the error thrown by the provided callback.
		/// @param {Function} callback Callback expected to throw.
		/// @param {String} value Expected error value.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertRaiseErrorValue = function(_func, _value, _message)
		{
			if (!is_callable(_func) )
			{
				return __AddAssertionLog(false, _message, $"Expected a callable callback, received {typeof(_func)}.");
			}

			try
			{
				_func();
			}
			catch (err)
			{
				// show_error wraps the message in a struct, so read the value from it.
				if (is_struct(err) ) err = err[$ "message"];

				return __AddAssertionLog(
					err == _value,
					_message,
					$"Error message is not equal to value: \"{err}\" != \"{_value}\""
				);
			}

			return __AddAssertionLog(false, undefined, "Error message was not thrown.");
		}

		/// @desc Tests that the provided callback runs without throwing.
		/// @param {Function} callback Callback expected to run safely.
		/// @param {String} [message=undefined] Custom message to output on failure.
		/// @return {Struct.CrispyCase} this instance
		static AssertDoesNotThrow = function(_func, _message)
		{
			if (!is_callable(_func) )
			{
				return __AddAssertionLog(false, _message, $"Expected a callable callback, received {typeof(_func)}.");
			}

			try
			{
				_func();
			}
			catch (err)
			{
				return __AddAssertionLog(false, _message, $"An unexpected error was thrown: {err}");
			}

			return __AddAssertionLog(true, undefined, undefined);
		}

		#endregion

		#region STATE QUERIES

		/// @desc Checks whether this test case is skipped.
		/// @return {Bool} Whether the test is skipped.
		static IsSkipped = function()
		{
			return __skipped;
		}

		#endregion

		#region GETTERS

		/// @desc Gets the class name of this test case.
		/// @return {String} Class name of the test case.
		static GetClass = function()
		{
			return __class;
		}

		/// @desc Gets the logs of this test case.
		/// @return {Array<Struct.CrispyLog>} Array of logs.
		static GetLogs = function()
		{
			return __logs;
		}

		/// @desc Gets the duration of the last run.
		/// @return {Real} Duration in seconds.
		static GetDuration = function()
		{
			return __duration;
		}

		#endregion

	#endregion
}