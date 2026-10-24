/// @desc Creates an asynchronous test case driven by Begin Step, Step, and End Step events.
/// @param {String} name Name of the case.
function CrispyCaseAsync(_name) : CrispyCase(_name, function() {}) constructor
{
	#region PRIVATE

		#region FIELDS

		/// @ignore
		/// @type {Bool}
		/// @desc Whether this case is asynchronous.
		__is_async = true;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether this case is currently running.
		__is_running = false;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether this case has completed.
		__is_complete = false;

		/// @ignore
		/// @type {Id.Instance}
		/// @desc Host instance that relays step events to this case.
		__host_id = noone;

		/// @ignore
		/// @type {Array<Struct>}
		/// @desc Checkpoints queued for this case.
		__checkpoints = [];

		/// @ignore
		/// @type {Real}
		/// @desc Index of the current checkpoint.
		__current_checkpoint = 0;

		/// @ignore
		/// @type {Real|Undefined}
		/// @desc Value of the timeout for this async case.
		__timeout_value = undefined;

		/// @ignore
		/// @type {String|Undefined}
		/// @desc Unit of the timeout for this async case.
		__timeout_unit = undefined;

		/// @ignore
		/// @type {Real}
		/// @desc Number of frames elapsed since the async case started.
		__elapsed_frames = 0;

		/// @ignore
		/// @type {Real}
		/// @desc Timestamp of when the async case started running.
		__run_started_at = 0;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether the suite is waiting for this case before finalizing.
		__suite_on_run_end_pending = false;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether a discovered script rebuilds the checkpoints on every start.
		__rebuild_on_start = false;

		#endregion

		#region METHODS

		/// @ignore
		/// @desc Queues a checkpoint for this async case.
		/// @param {String} event_name Name of the event to wait for.
		/// @param {Function} callback Callback for the checkpoint.
		/// @param {String} method_name Name of the method that called this function, used in error messages.
		/// @param {Struct|Id.Instance|Undefined} context Execution context for the callback.
		/// @return {Struct.CrispyCaseAsync} this instance
		static __QueueCheckpoint = function(_event_name, _func, _method_name, _context)
		{
			if (!is_callable(_func) )
			{
				__crispy_error($"CrispyCaseAsync.{_method_name}() 'callback' expected a callable value, received {typeof(_func)}.");
				return self;
			}

			if (!is_undefined(_context) )
			{
				var _is_instance_context = is_real(_context) && instance_exists(_context);
				if (!is_struct(_context) && !_is_instance_context)
				{
					__crispy_error(
						$"CrispyCaseAsync.{_method_name}() 'context' expected a struct, an instance id, "
						+ $"or undefined, received {typeof(_context)}."
					);
					return self;
				}
			}

			var _callback_context = is_undefined(_context) ? self : _context;

			array_push(__checkpoints, {
				event_name: _event_name,
				callback: method(_callback_context, _func),
				context: _callback_context,
			});

			return self;
		}

		/// @ignore
		/// @desc Runs the checkpoint that matches the event raised by the async host.
		/// @param {String} event_name Name of the event to handle.
		/// @return {Struct.CrispyCaseAsync} this instance
		static __HandleEvent = function(_event_name)
		{
			if (__is_complete || !__is_running) return self;
			if (__current_checkpoint >= array_length(__checkpoints) ) return Complete();

			var _checkpoint = __checkpoints[__current_checkpoint];
			if (_checkpoint.event_name != _event_name)
			{
				__CheckTimeout();
				return self;
			}

			if (is_real(_checkpoint.context) && !instance_exists(_checkpoint.context) )
			{
				return Fail("Async callback context no longer exists.");
			}

			var _result = _checkpoint.callback();

			// Only an explicit false keeps the checkpoint waiting for the next event of the same kind.
			if (!is_bool(_result) || _result)
			{
				++__current_checkpoint;
			}

			if (__current_checkpoint >= array_length(__checkpoints) && __is_running) Complete();
			if (__is_running) __CheckTimeout();

			return self;
		}

		/// @ignore
		/// @desc Fails the case when the configured timeout has elapsed.
		/// @return {Bool} Whether the case timed out.
		static __CheckTimeout = function()
		{
			if (is_undefined(__timeout_value) || is_undefined(__timeout_unit) ) return false;

			var _timed_out = false;

			switch (__timeout_unit)
			{
				case "frames":
					_timed_out = (__elapsed_frames >= __timeout_value);
				break;

				case "seconds":
					var _elapsed_seconds = (get_timer() - __run_started_at) / 1000000;
					_timed_out = (_elapsed_seconds >= __timeout_value);
				break;
			}

			if (_timed_out)
			{
				Fail($"Async case timed out after {string(__timeout_value)} {__timeout_unit}.");
			}

			return _timed_out;
		}

		/// @ignore
		/// @desc Creates the host instance that relays step events to this case.
		/// @return {Struct.CrispyCaseAsync} this instance
		static __CreateHost = function()
		{
			// Destroy any existing host before creating a new one.
			if (instance_exists(__host_id) )
			{
				with (__host_id) instance_destroy();
			}

			__host_id = instance_create_depth(0, 0, 0, o_crispy_async);
			variable_instance_set(__host_id, "async_case", self);

			return self;
		}

		/// @ignore
		/// @desc Destroys the host instance that relays step events to this case.
		/// @return {Struct.CrispyCaseAsync} this instance
		static __DestroyHost = function()
		{
			if (instance_exists(__host_id) )
			{
				with (__host_id) instance_destroy();
			}

			__host_id = noone;

			return self;
		}

		/// @ignore
		/// @desc Sets up a discovered script as the builder of the async checkpoints.
		/// @param {Real} script Index of the script asset.
		/// @return {Struct.CrispyCaseAsync} this instance
		static __Discover = function(_script)
		{
			if (!is_real(_script) )
			{
				__crispy_error($"CrispyCaseAsync.__Discover() 'script' expected a real number, received {typeof(_script)}.");
				return self;
			}

			if (!script_exists(_script) )
			{
				__crispy_error($"CrispyCaseAsync.__Discover() asset of index {_script} is not a script function.");
				return self;
			}

			__discovered_script = _script;
			__is_discovered = true;
			__test = method(self, _script);
			__rebuild_on_start = true;

			return self;
		}

		#endregion

	#endregion

	#region PUBLIC

		#region METHODS

		/// @desc Queues a callback to run on Begin Step.
		/// @param {Function} callback Callback for Begin Step.
		/// @param {Struct|Id.Instance} [context=undefined] Execution context for the callback; defaults to this async case.
		/// @return {Struct.CrispyCaseAsync} this instance
		static WaitBeginStep = function(_func, _context = undefined)
		{
			return __QueueCheckpoint("begin_step", _func, "WaitBeginStep", _context);
		}

		/// @desc Queues a callback to run on Step.
		/// @param {Function} callback Callback for Step.
		/// @param {Struct|Id.Instance} [context=undefined] Execution context for the callback; defaults to this async case.
		/// @return {Struct.CrispyCaseAsync} this instance
		static WaitStep = function(_func, _context = undefined)
		{
			return __QueueCheckpoint("step", _func, "WaitStep", _context);
		}

		/// @desc Queues a callback to run on End Step.
		/// @param {Function} callback Callback for End Step.
		/// @param {Struct|Id.Instance} [context=undefined] Execution context for the callback; defaults to this async case.
		/// @return {Struct.CrispyCaseAsync} this instance
		static WaitEndStep = function(_func, _context = undefined)
		{
			return __QueueCheckpoint("end_step", _func, "WaitEndStep", _context);
		}

		/// @desc Sets the timeout of this async case.
		/// @param {Real} value Timeout amount.
		/// @param {String} [unit="frames"] Either "frames" or "seconds".
		/// @return {Struct.CrispyCaseAsync} this instance
		static Timeout = function(_value, _unit = "frames")
		{
			if (!is_real(_value) )
			{
				__crispy_error($"CrispyCaseAsync.Timeout() 'value' expected a real number, received {typeof(_value)}.");
				return self;
			}

			if (!is_string(_unit) )
			{
				__crispy_alert(
					$"CrispyCaseAsync.Timeout() 'unit' expected a string, received {typeof(_unit)}, "
					+ "defaulting to 'frames'."
				);
				_unit = "frames";
			}

			if (_unit != "frames" && _unit != "seconds")
			{
				__crispy_alert($"CrispyCaseAsync.Timeout() 'unit' expected either 'frames' or 'seconds', received {_unit}.");
				_unit = "frames";
			}

			__timeout_value = _value;
			__timeout_unit = _unit;

			return self;
		}

		/// @desc Configures this async case with a builder callback that is executed on every Start.
		/// @param {Function} callback Callback that queues the checkpoints.
		/// @return {Struct.CrispyCaseAsync} this instance
		static Configure = function(_func)
		{
			if (!is_callable(_func) )
			{
				__crispy_error($"CrispyCaseAsync.Configure() 'callback' expected a callable value, received {typeof(_func)}.");
				return self;
			}

			__test = method(self, _func);
			__rebuild_on_start = true;

			return self;
		}

		/// @desc Starts the async case and creates its host instance.
		/// @return {Struct.CrispyCaseAsync} this instance
		static Start = function()
		{
			if (__skipped)
			{
				__is_running = false;
				__is_complete = true;
				__duration = 0;

				return self;
			}

			ClearLogs();
			__is_complete = false;
			__is_running = true;
			__current_checkpoint = 0;
			__elapsed_frames = 0;
			__run_started_at = get_timer();

			SetUp();
			OnRunBegin();

			if (__rebuild_on_start)
			{
				__checkpoints = [];
				__test();
			}

			__CreateHost();

			if (array_length(__checkpoints) == 0) Complete();

			return self;
		}

		/// @desc Alias for Start(), kept for compatibility with the synchronous case lifecycle.
		/// @return {Struct.CrispyCaseAsync} this instance
		static Run = function()
		{
			return Start();
		}

		/// @desc Completes the async case and releases its host instance.
		/// @return {Struct.CrispyCaseAsync} this instance
		static Complete = function()
		{
			if (__is_complete) return self;

			__is_running = false;
			__is_complete = true;
			__DestroyHost();

			OnRunEnd();
			TearDown();

			__duration = (get_timer() - __run_started_at) / 1000000;

			return self;
		}

		/// @desc Fails the async case and completes it.
		/// @param {String} [message="Async case failed."] Failure message.
		/// @return {Struct.CrispyCaseAsync} this instance
		static Fail = function(_message = "Async case failed.")
		{
			AddLog(new CrispyLog(self, {
				__pass: false,
				__msg: _message,
			}) );

			return Complete();
		}

		/// @desc Handles Begin Step from the async host.
		/// @return {Struct.CrispyCaseAsync} this instance
		static OnBeginStep = function()
		{
			if (__is_running)
			{
				++__elapsed_frames;
				__HandleEvent("begin_step");
			}

			return self;
		}

		/// @desc Handles Step from the async host.
		/// @return {Struct.CrispyCaseAsync} this instance
		static OnStep = function()
		{
			if (__is_running)
			{
				__HandleEvent("step");
			}

			return self;
		}

		/// @desc Handles End Step from the async host.
		/// @return {Struct.CrispyCaseAsync} this instance
		static OnEndStep = function()
		{
			if (__is_running)
			{
				__HandleEvent("end_step");
			}

			return self;
		}

		/// @desc Converts the async case into a short debug representation.
		/// @return {String} Debug representation of the async case.
		static toString = function()
		{
			return $"<Crispy Async Case(\"{__name}\")>";
		}

		#endregion

		#region STATE QUERIES

		/// @desc Returns whether this case is asynchronous.
		/// @return {Bool} Always true for an async case.
		static IsAsync = function()
		{
			return __is_async;
		}

		/// @desc Returns whether this case is currently running.
		/// @return {Bool} Whether the case is running.
		static IsRunning = function()
		{
			return __is_running;
		}

		/// @desc Returns whether this case has finished running.
		/// @return {Bool} Whether the case is complete.
		static IsComplete = function()
		{
			return __is_complete;
		}

		/// @desc Alias for IsComplete().
		/// @return {Bool} Whether the case is complete.
		static IsFinished = function()
		{
			return __is_complete;
		}

		#endregion

	#endregion
}