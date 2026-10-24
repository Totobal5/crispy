/// @desc Holds the test suites and iterates through them, running and updating their tests.
/// @param {String} name Name of the runner.
function CrispyRunner(_name) : CrispyTest(_name) constructor
{
	#region PRIVATE

		#region FIELDS

		/// @ignore
		/// @type {Real}
		/// @desc Timestamp of when the run started.
		__start_time = 0;

		/// @ignore
		/// @type {Real}
		/// @desc Timestamp of when the run stopped.
		__stop_time = 0;

		/// @ignore
		/// @type {Real}
		/// @desc Total run time in microseconds.
		__total_time = 0;

		/// @ignore
		/// @type {String}
		/// @desc Total run time formatted for the report.
		__display_time = "0";

		/// @ignore
		/// @type {Array<Struct.CrispySuite>}
		/// @desc Test suites registered in the runner.
		__suites = [];

		/// @ignore
		/// @type {Array<Struct.CrispyLog>}
		/// @desc Logs captured for the current run.
		__logs = [];

		/// @ignore
		/// @type {Array<Struct>|Undefined}
		/// @desc Cached script functions, filled by the first call to Discover().
		__discovered = undefined;

		/// @ignore
		/// @type {Real}
		/// @desc Index of the suite that is currently running.
		__current_suite_index = 0;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether the runner is currently running.
		__is_running = false;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether the runner has completed its current run.
		__is_complete = false;

		#endregion

		#region METHODS

		/// @ignore
		/// @desc Default output sink, replaced by the callback passed to Output().
		/// @param {String} message Text written to the Output Window.
		static __Output = function(_message)
		{
			show_debug_message(_message);
		}

		/// @ignore
		/// @desc Advances the runner through the suites, running and updating them as needed.
		/// @return {Struct.CrispyRunner} this instance
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

		/// @ignore
		/// @desc Caches every global script function that can be discovered.
		/// @return {Struct.CrispyRunner} this instance
		static __CacheScripts = function()
		{
			__discovered = [];

			// Custom script ids start at 100000 and can contain gaps, so the scan keeps going until
			// enough consecutive misses suggest that the custom range has ended.
			var _max_missing_streak = 2048;
			var _missing_streak = 0;
			var _script_id = 100000;

			while (_missing_streak < _max_missing_streak)
			{
				if (!script_exists(_script_id) )
				{
					++_missing_streak;
					++_script_id;

					continue;
				}

				_missing_streak = 0;

				var _script_name = script_get_name(_script_id);

				// Generated event scripts are not discoverable, only global script functions are.
				if (string_count("_gml_Object_", _script_name) != 0 || string_count("_gml_GlobalScript_", _script_name) != 0)
				{
					++_script_id;

					continue;
				}

				array_push(__discovered, {
					name: _script_name,
					func: _script_id,
					discovered: false
				});

				__crispy_alert($"Discovered script function: {_script_name} ({_script_id}).");
				++_script_id;
			}

			__crispy_alert($"Stopped discovery scan after {_max_missing_streak} consecutive missing script IDs.");

			return self;
		}

		/// @ignore
		/// @desc Aggregates the logs of a single case into one runner log.
		/// @param {Struct.CrispyCase|Struct.CrispyCaseAsync} test_case Case whose logs are aggregated.
		/// @return {Struct.CrispyRunner} this instance
		static __CaptureCaseLogs = function(_test_case)
		{
			var _pass = true;
			var _failure_lines = [];

			var i = 0;
			repeat (array_length(_test_case.__logs) )
			{
				var _log = _test_case.__logs[i];

				if (!_log.__pass)
				{
					_pass = false;

					var _line = _log.__msg;
					if (is_undefined(_line) || _line == "") _line = _log.__helper_text;
					if (is_undefined(_line) || _line == "") _line = "Assertion failed.";

					array_push(_failure_lines, $"[{string(array_length(_failure_lines) + 1)}] {_line}");
				}

				++i;
			}

			var _msg = undefined;
			var _helper_text = undefined;

			if (!_pass)
			{
				_msg = $"{string(array_length(_failure_lines) )} assertion failure(s)";

				var _details = "";
				var j = 0;
				repeat (array_length(_failure_lines) )
				{
					if (j > 0) _details += "\n";

					_details += _failure_lines[j];
					++j;
				}

				_helper_text = _details;
			}

			AddLog(new CrispyLog(_test_case, {
				__pass: _pass,
				__msg: _msg,
				__helper_text: _helper_text,
				__duration: _test_case.__duration,
				__skipped: _test_case.__skipped,
			}) );

			return self;
		}

		/// @ignore
		/// @desc Counts the passing logs of the current run.
		/// @return {Real} Number of passing logs.
		static __CountPassingLogs = function()
		{
			var _passed = 0;
			var _len = array_length(__logs);

			var i = 0;
			repeat (_len)
			{
				if (__logs[i].__pass) ++_passed;

				++i;
			}

			return _passed;
		}

		/// @ignore
		/// @desc Writes one row of single character results, wrapped every CRISPY_STATUS_OUTPUT_LENGTH characters.
		/// @param {Real} length Number of logs to represent.
		static __OutputStatusRow = function(_length)
		{
			if (CRISPY_STATUS_OUTPUT_LENGTH == 0)
			{
				Output("");
				return;
			}

			var _row_len = abs(CRISPY_STATUS_OUTPUT_LENGTH);
			var _row = "";
			var _column = 0;
			var _text = "";

			for (var i = 0; i < _length; ++i)
			{
				_row += __logs[i].__pass ? CRISPY_PASS_MSG_SILENT : CRISPY_FAIL_MSG_SILENT;
				++_column;

				if (_row_len > 0 && _column == _row_len && i != _length - 1)
				{
					_text += _row + "\n";
					_row = "";
					_column = 0;
				}
			}

			Output(_text + _row);
		}

		#endregion

	#endregion

	#region PUBLIC

		#region METHODS

		/// @desc Adds a log to the array of logs.
		/// @param {Struct.CrispyLog} log Log to add.
		/// @return {Struct.CrispyRunner} this instance
		static AddLog = function(_log)
		{
			array_push(__logs, _log);

			return self;
		}

		/// @desc Adds the logs of a log, a case, or a suite to the runner logs.
		/// @param {Struct.CrispyLog|Struct.CrispyCase|Struct.CrispyCaseAsync|Struct.CrispySuite} input
		///       Value whose logs are captured.
		/// @return {Struct.CrispyRunner} this instance
		static CaptureLogs = function(_input)
		{
			if (is_instanceof(_input, CrispyLog) )
			{
				AddLog(_input);

				return self;
			}

			if (is_instanceof(_input, CrispyCase) || is_instanceof(_input, CrispyCaseAsync) )
			{
				__CaptureCaseLogs(_input);

				return self;
			}

			if (is_instanceof(_input, CrispySuite) )
			{
				var i = 0;
				repeat (array_length(_input.__tests) )
				{
					CaptureLogs(_input.__tests[i]);
					++i;
				}

				return self;
			}

			__crispy_error(
				"CrispyRunner.CaptureLogs() 'input' expected an instance of CrispyLog, CrispyCase, "
				+ $"or CrispySuite, received {__crispy_type(_input)}."
			);

			return self;
		}

		/// @desc Adds a test suite to the array of suites.
		/// @param {Struct.CrispySuite} test_suite Suite to add.
		/// @return {Struct.CrispyRunner} this instance
		static AddTestSuite = function(_test_suite)
		{
			if (!is_instanceof(_test_suite, CrispySuite) )
			{
				__crispy_error(
					"CrispyRunner.AddTestSuite() 'test_suite' expected an instance of CrispySuite, "
					+ $"received {__crispy_type(_test_suite)}."
				);
				return self;
			}

			_test_suite.__parent = self;
			array_push(__suites, _test_suite);

			return self;
		}

		/// @desc Builds a horizontal row string used to visually separate sections of the report.
		/// @param {String} [str="-"] String to repeat.
		/// @param {Real} [count=70] Number of times to repeat the string.
		/// @return {String} Horizontal row of characters.
		static Hr = function(_str = "-", _count = 70)
		{
			var _hr = "";

			repeat (_count) { _hr += _str; }

			return _hr;
		}

		/// @desc Writes a string to the output sink, or replaces the sink with a callback.
		/// @param {String|Function} input String to write or callback that replaces the output sink.
		/// @return {Struct.CrispyRunner} this instance
		static Output = function(_input)
		{
			if (is_undefined(_input) )
			{
				__crispy_error("CrispyRunner.Output() expected 1 argument, received 0 argument(s).");
				return self;
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
				__crispy_error($"CrispyRunner.Output() 'input' expected either a string or a method, received {_type}.");
			}

			return self;
		}

		/// @desc Runs the suites and logs the results.
		/// @return {Struct.CrispyRunner} this instance
		static Run = function()
		{
			SetUp();
			__current_suite_index = 0;
			__is_running = true;
			__is_complete = false;

			__AdvanceSuites();

			return self;
		}

		/// @desc Updates the active suite and advances the run when asynchronous suites complete.
		/// @return {Struct.CrispyRunner} this instance
		static Update = function()
		{
			if (!__is_running) return self;

			__AdvanceSuites();

			return self;
		}

		/// @desc Registers or runs the setup callback, clearing the logs and starting the timer first.
		/// @param {Function} [callback=undefined] Callback to run at the start of the run; omit it to run the registered one.
		/// @return {Struct.CrispyRunner} this instance
		static SetUp = function(_func = undefined)
		{
			if (!is_undefined(_func) )
			{
				__SetUp = method(self, _func);

				return self;
			}

			__logs = [];
			__start_time = get_timer();
			__is_complete = false;

			if (is_callable(__SetUp) ) __SetUp();

			return self;
		}

		/// @desc Registers or runs the teardown callback; running it writes the report of the current run.
		/// @param {Function} [callback=undefined] Callback to run at the end of the run;
		///       omit it to run the registered one and print the report.
		/// @return {Struct.CrispyRunner} this instance
		static TearDown = function(_func = undefined)
		{
			if (!is_undefined(_func) )
			{
				__TearDown = method(self, _func);

				return self;
			}

			if (CRISPY_SILENCE_PASSING_TESTS_OUTPUT)
			{
				__crispy_alert("Passing test messages are silenced.");
			}

			__stop_time = get_timer();
			__total_time = __stop_time - __start_time;
			__display_time = string_format(__total_time / 1000000, 0, CRISPY_TIME_PRECISION);

			var _len = array_length(__logs);
			var _passed_tests = __CountPassingLogs();

			__OutputStatusRow(_len);

			Output(Hr() );

			for (var i = 0; i < _len; ++i)
			{
				if (CRISPY_SILENCE_PASSING_TESTS_OUTPUT && __logs[i].__pass) continue;

				var _msg = __logs[i].GetMsg();
				if (_msg != "") Output(_msg);
			}

			var _string_tests = (_len == 1) ? "test" : "tests";

			Output("");
			Output($"{string(_len)} {_string_tests} ran in {__display_time}s");

			if (_passed_tests == _len)
			{
				Output(string_upper(CRISPY_PASS_MSG_VERBOSE) );
			}
			else
			{
				Output($"{string_upper(CRISPY_FAIL_MSG_VERBOSE)}ED (failures=={string(_len - _passed_tests)})");
			}

			// Run the callback registered by the project through TearDown().
			if (is_method(__TearDown) ) __TearDown();

			return self;
		}

		/// @desc Discovers the test functions of the scripts and adds them as cases of a suite.
		/// @param {Struct.CrispySuite} [test_suite=undefined] Suite that receives the discovered cases;
		///       a temporary suite is created when omitted.
		/// @param {String} [script_start_pattern="test_"] Prefix that identifies a discoverable script function.
		/// @return {Struct.CrispyRunner} this instance
		static Discover = function(_test_suite = undefined, _script_start_pattern = "test_")
		{
			if (!is_string(_script_start_pattern) )
			{
				__crispy_error(
					"CrispyRunner.Discover() 'script_start_pattern' expected a string, "
					+ $"received {typeof(_script_start_pattern)}."
				);
				return self;
			}

			var _pattern_len = string_length(_script_start_pattern);

			if (_pattern_len == 0)
			{
				__crispy_error("CrispyRunner.Discover() 'script_start_pattern' cannot be an empty string.");
				return self;
			}

			// The cache is shared by every suite, so the scan runs once per runner.
			if (is_undefined(__discovered) ) __CacheScripts();

			if (!is_undefined(_test_suite) )
			{
				if (!is_instanceof(_test_suite, CrispySuite) )
				{
					__crispy_error(
						"CrispyRunner.Discover() 'test_suite' expected an instance of CrispySuite, "
						+ $"received {__crispy_type(_test_suite)}."
					);
					return self;
				}

				// Discover needs the runner of the suite to register the cases against it.
				if (_test_suite.__parent != self)
				{
					__crispy_error(
						$"CrispyRunner.Discover() 'test_suite' parent is not self. The provided CrispySuite "
						+ $"may not have been added to {__name} prior to calling Discover."
					);
					return self;
				}
			}

			var _created_test_suite = is_undefined(_test_suite);
			if (_created_test_suite) _test_suite = new CrispySuite("__discovered_test_suite__");

			var _len = array_length(__discovered);
			for (var i = 0; i < _len; ++i)
			{
				var _script = __discovered[i];
				if (_script.discovered) continue;

				var _script_name = _script.name;
				if (string_length(_script_name) < _pattern_len) continue;
				if (string_copy(_script_name, 1, _pattern_len) != _script_start_pattern) continue;

				var _is_async_script = (string_pos("_async", _script_name) > 0);
				var _test_case = _is_async_script
					? new CrispyCaseAsync(_script_name)
					: new CrispyCase(_script_name, function() {});

				_test_case.__Discover(_script.func);
				_test_suite.AddCase(_test_case);
				_script.discovered = true;
			}

			if (!_created_test_suite) return self;

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

			return self;
		}

		/// @desc Converts the runner into a short debug representation.
		/// @return {String} Debug representation of the runner.
		static toString = function()
		{
			return $"<Crispy Runner(\"{__name}\")>";
		}

		#endregion

		#region STATE QUERIES

		/// @desc Returns whether the runner is currently running.
		/// @return {Bool} Whether the runner is running.
		static IsRunning = function()
		{
			return __is_running;
		}

		/// @desc Returns whether the runner has completed its current run.
		/// @return {Bool} Whether the runner is complete.
		static IsComplete = function()
		{
			return __is_complete;
		}

		#endregion

	#endregion
}