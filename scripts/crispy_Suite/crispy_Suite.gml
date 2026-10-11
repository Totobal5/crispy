/// @desc Creates a suite that groups related test cases.
/// @param {String} name Name of suite
/// @returns {Struct.CrispySuite} New suite.
function CrispySuite(_name) : CrispyTest(_name) constructor 
{
	/// @ignore
	/// @desc Parent suite of this suite
	/// @type {Struct.CrispySuite}
	__parent = undefined;

	/// @ignore
	/// @desc Array of tests in the suite
	/// @type {Array}
	__tests = [];

	/// @ignore
	/// @desc Whether the suite is currently running
	/// @type {Bool}
	__is_running = false;

	/// @ignore
	/// @desc Whether the suite has completed
	/// @type {Bool}
	__is_complete = false;
	
	#region METHODS

	/// @desc Adds CrispyCase to array of cases
	/// @param {Struct} test_case CrispyCase to add
	/// @returns {Struct.CrispySuite} Self for chaining
	static AddCase = function(_test_case)
	{
		var _is_case = is_instanceof(_test_case, CrispyCase) || is_instanceof(_test_case, CrispyCaseAsync);
		if (!_is_case)
		{
			var _instanceof = instanceof(_test_case);
			var _type = !is_undefined(_instanceof) ? _instanceof : typeof(_test_case);
			__crispy_error($"CrispySuite.AddCase() '_test_case' expected an instance of CrispyCase or CrispyCaseAsync, received {_type}.");
		}
		
		_test_case.__parent = self;
		array_push(__tests, _test_case);
		
		return self;
	}

	/// @desc Returns whether the suite is currently running.
	/// @returns {Bool}
	static IsRunning = function()
	{
		return __is_running;
	}

	/// @desc Returns whether the suite has completed.
	/// @returns {Bool}
	static IsComplete = function()
	{
		return __is_complete;
	}
	
	/// @desc Runs tests
	/// @returns {Struct.CrispySuite} Self for chaining
	static Run = function()
	{
		__is_complete = false;
		__is_running = true;
		SetUp();

		var _has_async_running = false;
		var i = 0; repeat(array_length(__tests) )
		{
			var _test = __tests[i++];
			OnRunBegin();

			if (is_instanceof(_test, CrispyCaseAsync) )
			{
				_test.__suite_on_run_end_pending = true;
				_test.Start();

				if (_test.IsComplete() )
				{
					if (_test.__suite_on_run_end_pending)
					{
						OnRunEnd();
						_test.__suite_on_run_end_pending = false;
					}
				}
				else
				{
					_has_async_running = true;
				}
			}
			else
			{
				_test.Run();
				OnRunEnd();
			}
		}

		if (!_has_async_running) { __FinalizeRun(); }
		
		return self;
	}

	/// @desc Updates asynchronous tests and finalizes the suite when they complete.
	/// @returns {Struct.CrispySuite} Self for chaining
	static Update = function()
	{
		if (!__is_running) { return self; }

		var _has_async_running = false;
		var _i = 0; repeat(array_length(__tests) )
		{
			var _test = __tests[_i++];
			if (!is_instanceof(_test, CrispyCaseAsync) ) continue;

			if (_test.IsRunning() )
			{
				_has_async_running = true;
				continue;
			}

			if (_test.__suite_on_run_end_pending && _test.IsComplete())
			{
				OnRunEnd();
				_test.__suite_on_run_end_pending = false;
			}
		}

		if (!_has_async_running) { __FinalizeRun(); }

		return self;
	}

	/// @ignore
	/// @desc Finalizes the suite when all tests have completed.
	/// @returns {Struct.CrispySuite} Self for chaining
	static __FinalizeRun = function()
	{
		if (__is_complete) { return self; }

		TearDown();
		__is_running = false;
		__is_complete = true;

		return self;
	}

	/// @returns {String}
	static toString = function()
	{
		return $"<Crispy Suite('{__name}')>";
	}

	#endregion
}