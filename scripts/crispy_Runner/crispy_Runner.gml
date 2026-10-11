/// @desc Runner to hold test suites and iterates through each CrispySuite, running its tests
/// @param {String} name - Name of runner
function CrispyRunner(_name) : CrispyTest(_name) constructor
{
	/// @ignore
	/// @desc Start time of the runner
	/// @type {Real}
	__start_time = 0;

	/// @ignore
	/// @desc Stop time of the runner
	/// @type {Real}
	__stop_time = 0;

	/// @ignore
	/// @desc Total time of the runner
	/// @type {Real}
	__total_time = 0;

	/// @ignore
	/// @desc Display time of the runner
	/// @type {String}
	__display_time = "0";

	/// @ignore
	/// @desc Array of test suites
	/// @type {Array<Struct.CrispySuite>}
	__suites = [];

	/// @ignore
	/// @desc Array of logs
	/// @type {Array<Struct.CrispyLog>}
	__logs = [];

	/// @ignore
	/// @desc Array of discovered scripts
	/// @type {Array}
	__discovered = undefined;

	/// @ignore
	/// @desc Index of the current suite being run
	/// @type {Real}
	__current_suite_index = 0;

	/// @ignore
	/// @desc Whether the runner is currently running
	/// @type {Bool}
	__is_running = false;

	/// @ignore
	/// @desc Whether the runner has completed its current run
	/// @type {Bool}
	__is_complete = false;

	#region METHODS

	/// @desc Adds a Log to the array of logs
	/// @param {Struct.CrispyLog} log Log struct to add to logs
	/// @returns {Struct.CrispyRunner} Self for chaining
	static AddLog = function(_log)
	{
		array_push(__logs, _log);
		return self;
	}

	/// @desc Adds Logs to the array of logs
	/// @param {Struct.CrispyLog|Struct.CrispyRunner|Struct.CrispySuite} input Adds logs of the input to logs
	/// @returns {Struct.CrispyRunner} Self for chaining
	static CaptureLogs = function(_input)
	{
		var i;
		var _kind = "";
		if (is_instanceof(_input, CrispyLog) ) _kind = "CrispyLog";
		else if (is_instanceof(_input, CrispyCase) || is_instanceof(_input, CrispyCaseAsync) ) _kind = "CrispyCase";
		else if (is_instanceof(_input, CrispySuite) ) _kind = "CrispySuite";

		switch (_kind)
		{
			case "CrispyLog":
				AddLog(_input);
			break;

			case "CrispyCase":
				var _case_logs_len = array_length(_input.__logs);
				var _case_pass = true;
				var _case_msg = undefined;
				var _case_helper_text = undefined;
				var _failure_lines = [];
				var _failure_index = 0;

				i = 0; repeat (_case_logs_len)
				{
					var _log = _input.__logs[i];
					if (!_log.__pass)
					{
						_case_pass = false;
						++_failure_index;

						var _line = _log[$ "__msg"];
						if (is_undefined(_line) || _line == "") { _line = _log[$ "__helper_text"]; }
						if (is_undefined(_line) || _line == "") { _line = "Assertion failed."; }

						array_push(_failure_lines, $"[{string(_failure_index)}] {_line}");
					}

					++i;
				}

				if (!_case_pass)
				{
					_case_msg = $"{string(_failure_index)} assertion failure(s)";

					var _details = "";
					var j = 0; repeat (array_length(_failure_lines))
					{
						if (j > 0) _details += "\n";
						_details += _failure_lines[j];
						++j;
					}

					_case_helper_text = _details;
				}

				AddLog(new CrispyLog(_input, {
					__pass:	_case_pass,
					__msg:	_case_msg,
					__helper_text:	_case_helper_text,
					__duration:		_input.__duration,
					__skipped:		_input.__skipped,
				}) );
			break;
			
			case "CrispySuite":
				i=0; repeat (array_length(_input.__tests) )
				{
					var _case = _input.__tests[i];
					CaptureLogs(_case);
					++i;
				}
			break;

			default:
				__crispy_error($"CrispyRunner.CaptureLogs() '_input' expected an instance of either CrispyLog, CrispyCase, or CrispySuite, received {instanceof(_input)}.");
			break;
		}

		return self;
	}

	/// @desc Adds TestSuite to array of suites
	/// @param {Struct} test_suite - TestSuite to add
	/// @returns {Struct.CrispyRunner} Self for chaining
	static AddTestSuite = function(_test_suite)
	{
		if (!is_instanceof(_test_suite, CrispySuite) )
		{
			__crispy_error($"CrispyRunner.AddTestSuite() '_test_suite' expected an instance of CrispySuite, received {instanceof(_test_suite)}.");
		}

		_test_suite.__parent = self;
		array_push(__suites, _test_suite);
		return self;
	}

	/// @desc Creates a horizontal row string used to visually separate sections
	/// @param {String} [str="-"] String to concat n times
	/// @param {Real} [count=70] Number of times to concat str
	/// @returns {String} String of horizontal row
	static Hr = function(_str = "-", _count = 70)
	{
		var _hr = ""; repeat(_count) { _hr += _str; }
		return _hr;
	}

	/// @desc Returns whether the runner is currently active.
	/// @returns {Bool}
	static IsRunning = function()
	{
		return __is_running;
	}

	/// @desc Returns whether the runner has completed its current run.
	/// @returns {Bool}
	static IsComplete = function()
	{
		return __is_complete;
	}
	
	/// @desc Runs test suites and logs results
	/// @returns {Struct.CrispyRunner} Self for chaining
	static Run = function()
	{
		SetUp();
		__current_suite_index = 0;
		__is_running = true;
		__is_complete = false;
		__AdvanceSuites();

		return self;
	}

	/// @desc Updates the active suite and advances the run when async suites complete.
	/// @returns {Struct.CrispyRunner} Self for chaining
	static Update = function()
	{
		if (!__is_running) return self;
		__AdvanceSuites();

		return self;
	}

	/// @desc Clears logs, starts timer, and runs __SetUp
	/// @param {Function} [callback] Callback to override __SetUp with
	/// @returns {Struct.CrispyRunner} Self for chaining
	static SetUp = function(_func)
	{
		if (is_undefined(_func) )
		{
			__logs = [];
			__start_time = get_timer();
			__is_complete = false;

			if (is_callable(__SetUp) ) __SetUp();
		}
		else
		{
			__SetUp = method(self, _func);
		}

		return self;
	}

	/// @desc Callback run after the test to clean up its state
	/// @param {Function} [callback] Callback to override __TearDown with
	/// @returns {Struct.CrispyRunner} Self for chaining
	static TearDown = function(_func)
	{
		if (!is_undefined(_func) )
		{
			__TearDown = method(self, _func);
		}
		else
		{
			if (CRISPY_SILENCE_PASSING_TESTS_OUTPUT)
			{
				__crispy_alert("Passing test messages are silenced.");
			}
			
			// Get total run time
			__stop_time = get_timer();
			__total_time = __stop_time - __start_time;
			__display_time = string_format(__total_time / 1000000, 0, CRISPY_TIME_PRECISION);

			// Display silent test results
			var _passed_tests = 0;
			var _len = array_length(__logs);
			var _t = "";
			var _j = 0;

			if (_len > 0 && CRISPY_STATUS_OUTPUT_LENGTH != 0)
			{
				var _row_len = abs(CRISPY_STATUS_OUTPUT_LENGTH);
				var _row = "";
				for (var i = 0; i < _len; ++i)
				{
					if (__logs[i].__pass)
					{
						++_passed_tests;
						_row += CRISPY_PASS_MSG_SILENT;
					}
					else
					{
						_row += CRISPY_FAIL_MSG_SILENT;
					}
					++_j;

					if (_row_len > 0 && _j == _row_len && i != _len - 1)
					{
						_t += _row + "\n";
						_row = "";
						_j = 0;
					}
				}
				_t += _row;
			}
			else
			{
				var _index = 0; repeat (_len)
				{
					if (__logs[_index].__pass) { ++_passed_tests; }
					++_index;
				}
			}

			Output(_t);

			// Horizontal row
			Output(Hr() );
			
			// Show individual log messages
			var i = 0; repeat (_len)
			{
				// _passed_tests already counted in status output loop above

				if (!CRISPY_SILENCE_PASSING_TESTS_OUTPUT || !__logs[i].__pass)
				{
					var _msg = __logs[i].GetMsg();
					if (_msg != "") { Output(_msg); }
				}

				++i;
			}

			// Finish by showing entire time it took to run the tests
			var _string_tests = _len == 1 ? "test" : "tests";
			Output("");
			Output(string(_len) + " " + _string_tests + " ran in " + __display_time + "s");

			if (_passed_tests == _len)
			{
				Output(string_upper(CRISPY_PASS_MSG_VERBOSE));
			}
			else
			{
				Output(string_upper(CRISPY_FAIL_MSG_VERBOSE) + "ED (failures==" + string(_len - _passed_tests) + ")");
			}

			// Run TearDown method
			if (is_method(__TearDown) ) { __TearDown(); }
		}
		
		return self;
	}

	/// @desc Function for discovering individual test functions within scripts, and adds them to a TestSuite
	/// @param {Struct.CrispySuite} [test_suite=undefined] TestSuite to add discovered test script to, else create a temporary TestSuite
	/// @param {String} [script_start_pattern="test_"] String that script functions need to start with in order to be discoverable
	/// @returns {Struct.CrispyRunner} Self for chaining
	static Discover = function(_test_suite, _script_start_pattern = "test_")
	{
		if (!is_string(_script_start_pattern) )
		{
			__crispy_error($"CrispyRunner.Discover() '_script_start_pattern' expected a string, received {typeof(_script_start_pattern)}.");
		}

		// Cache all script functions
		if (is_undefined(__discovered) )
		{
			__discovered = [];
			// Range of custom scripts is 100000 onwards
			var _missing_streak = 0;
			var _max_missing_streak = 2048;

			// Script IDs can contain gaps, so keep scanning until enough consecutive misses suggest the range ended.
			var i = 100000; while (_missing_streak < _max_missing_streak)
			{
				if (!script_exists(i) )
				{
					++_missing_streak;
					++i;
					continue;
				}

				_missing_streak = 0;
				
				var _script_name = script_get_name(i);
				// Skip adding functions that are not named script functions
				if (string_count("_gml_Object_", _script_name) != 0 || string_count("_gml_GlobalScript_", _script_name) != 0)
				{
					++i;
					continue;
				}

				array_push(__discovered, {
					name: _script_name,
					func: i,
					discovered: false
				});
				
				__crispy_alert($"Discovered script function: {_script_name} ({i}).");
				++i;
			}
			
			__crispy_alert($"Stopped discovery scan after {_max_missing_streak} consecutive missing script IDs.");
		}

		var _created_test_suite = is_undefined(_test_suite);

		// If value is passed for _test_suite
		if (!is_undefined(_test_suite) )
		{
			if (!is_instanceof(_test_suite, CrispySuite) )
			{
				var _instanceof = instanceof(_test_suite);
				var _type = !is_undefined(_instanceof) ? _instanceof : typeof(_test_suite);
				__crispy_error($"CrispyRunner.Discover() '_test_suite' expected an instance of CrispySuite, received {_type}.");
			}
			// Throw error if test_suite was not previously added to test_runner
			if (_test_suite.__parent != self)
			{
				__crispy_error($"CrispyRunner.Discover() '_test_suite' parent is not self.\nProvided CrispySuite may not have been added to {__name} prior to running Discover.");
			}
		}
		else
		{
			_test_suite = new CrispySuite("__discovered_test_suite__");
		}

		// Throw error if function pattern is an empty string
		var _pattern_len = string_length(_script_start_pattern);
		if (_pattern_len == 0)
		{
			__crispy_error($"CrispyRunner.Discover() '_script_start_pattern' cannot be an empty string.");
		}
		
		// Discover scripts matching the start pattern and add as test cases
		var _len = array_length(__discovered);
		for (var i = 0; i < _len; ++i)
		{
			var _script = __discovered[i];
			if (_script.discovered) continue;

			var _script_name = _script.name;
			if (string_length(_script_name) >= _pattern_len && string_copy(_script_name, 1, _pattern_len) == _script_start_pattern)
			{
				var _is_async_script = (string_pos("_async", _script_name) > 0);
				var _test_case = _is_async_script
					? new CrispyCaseAsync(_script_name)
					: new CrispyCase(_script_name, function(){});

				_test_case.__Discover(_script.func);
				_test_suite.AddCase(_test_case);
				_script.discovered = true;
			}
		}

		if (_created_test_suite)
		{
			if (array_length(_test_suite.__tests) == 0)
			{
				delete _test_suite;
				__crispy_alert($"{__name}.Discover() local CrispySuite deleted.");
			}
			else
			{
				AddTestSuite(_test_suite);
				__crispy_alert($"{__name}.Discover() local CrispySuite added: {_test_suite.__name}");
			}
		}

		return self;
	}

	/// @desc Writes a string or replaces the output callback.
	/// @param {String|Function} input String to output or callback to replace __Output
	static Output = function(_input)
	{
		if (is_undefined(_input) )
		{
			__crispy_error($"CrispyRunner.Output() expected 1 argument, received 0 argument(s).");
			return;
		}

		var _type = typeof(_input);
		if (_type == "string")
		{
			__Output(_input);
		}
		else if (_type == "method")
		{
			__Output = method(self, _input);
		}
		else
		{
			__crispy_error($"CrispyRunner.Output() '_input' expected either a string or method, received {_type}.");
		}

		return self;
	}

	/// @ignore
	/// @desc Function that gets called on output. This function can be overwritten by a function passed into the Output() function
	/// @param {String} message By default, prints string to Output Console
	static __Output = function(_message)
	{
		show_debug_message(_message);
	}

	/// @ignore
	/// @desc Advances the runner through the test suites, running and updating them as needed.
	/// @returns {Struct.CrispyRunner} Self for chaining
	static __AdvanceSuites = function()
	{
		var _len = array_length(__suites);
		while (__current_suite_index < _len)
		{
			var _suite = __suites[__current_suite_index];

			if (!_suite.IsRunning() && !_suite.IsComplete() )
			{
				OnRunBegin();
				_suite.Run();
			}
			else if (_suite.IsRunning() )
			{
				_suite.Update();
			}

			if (_suite.IsComplete() )
			{
				CaptureLogs(_suite);
				OnRunEnd();
				++__current_suite_index;

				continue;
			}

			return self;
		}

		if (__is_running)
		{
			__is_running = false;
			__is_complete = true;

			TearDown();
		}

		return self;
	}

	/// @returns {String}
	static toString = function()
	{
		return $"<Crispy Runner(\"{__name}\")>";
	}

	#endregion
}
