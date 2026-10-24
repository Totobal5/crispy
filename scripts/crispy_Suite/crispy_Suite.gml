/// @desc Creates a suite that groups related test cases.
/// @param {String} name Name of the suite.
function CrispySuite(_name) : CrispyTest(_name) constructor
{
	#region PRIVATE

		#region FIELDS

		/// @ignore
		/// @type {Struct.CrispySuite|Struct.CrispyRunner|Undefined}
		/// @desc Runner that owns this suite.
		__parent = undefined;

		/// @ignore
		/// @type {Array<Struct.CrispyCase|Struct.CrispyCaseAsync>}
		/// @desc Test cases registered in the suite.
		__tests = [];

		/// @ignore
		/// @type {Bool}
		/// @desc Whether the suite is currently running.
		__is_running = false;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether the suite has completed.
		__is_complete = false;

		#endregion

		#region METHODS

		/// @ignore
		/// @desc Finalizes the suite once every test has completed.
		/// @return {Struct.CrispySuite} this instance
		static __FinalizeRun = function()
		{
			if (__is_complete) return self;

			TearDown();
			__is_running = false;
			__is_complete = true;

			return self;
		}

		#endregion

	#endregion

	#region PUBLIC

		#region METHODS

		/// @desc Adds a test case to the suite.
		/// @param {Struct.CrispyCase|Struct.CrispyCaseAsync} test_case Case to add.
		/// @return {Struct.CrispySuite} this instance
		static AddCase = function(_test_case)
		{
			if (!is_instanceof(_test_case, CrispyCase) && !is_instanceof(_test_case, CrispyCaseAsync) )
			{
				__crispy_error(
					"CrispySuite.AddCase() 'test_case' expected an instance of CrispyCase or "
					+ $"CrispyCaseAsync, received {__crispy_type(_test_case)}."
				);
				return self;
			}

			_test_case.__parent = self;
			array_push(__tests, _test_case);

			return self;
		}

		/// @desc Runs every test in the suite.
		/// @return {Struct.CrispySuite} this instance
		static Run = function()
		{
			__is_complete = false;
			__is_running = true;
			SetUp();

			var _has_async_running = false;

			var i = 0;
			repeat (array_length(__tests) )
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

			if (!_has_async_running) __FinalizeRun();

			return self;
		}

		/// @desc Updates the asynchronous tests and finalizes the suite once they complete.
		/// @return {Struct.CrispySuite} this instance
		static Update = function()
		{
			if (!__is_running) return self;

			var _has_async_running = false;

			var i = 0;
			repeat (array_length(__tests) )
			{
				var _test = __tests[i++];
				if (!is_instanceof(_test, CrispyCaseAsync) ) continue;

				if (_test.IsRunning() )
				{
					_has_async_running = true;
					continue;
				}

				if (_test.__suite_on_run_end_pending && _test.IsComplete() )
				{
					OnRunEnd();
					_test.__suite_on_run_end_pending = false;
				}
			}

			if (!_has_async_running) __FinalizeRun();

			return self;
		}

		/// @desc Converts the suite into a short debug representation.
		/// @return {String} Debug representation of the suite.
		static toString = function()
		{
			return $"<Crispy Suite('{__name}')>";
		}

		#endregion

		#region STATE QUERIES

		/// @desc Returns whether the suite is currently running.
		/// @return {Bool} Whether the suite is running.
		static IsRunning = function()
		{
			return __is_running;
		}

		/// @desc Returns whether the suite has completed.
		/// @return {Bool} Whether the suite is complete.
		static IsComplete = function()
		{
			return __is_complete;
		}

		#endregion

	#endregion
}
