/// @desc Base constructor for Crispy test containers.
/// @param {String} name Name of the container.
function CrispyTest(_name) constructor
{
	#region PRIVATE

		#region FIELDS

		/// @type {Struct}
		/// @desc Shared variables accessible from every Crispy test container.
		static vars = {};

		/// @ignore
		/// @type {String}
		/// @desc Name of the container.
		__name = _name;

		#endregion

		#region CALLBACKS

		/// @ignore
		/// @type {Function|Undefined}
		/// @desc Callback to execute in the setup.
		__SetUp = undefined;

		/// @ignore
		/// @type {Function|Undefined}
		/// @desc Callback to execute in the teardown.
		__TearDown = undefined;

		/// @ignore
		/// @type {Function|Undefined}
		/// @desc Callback to execute at the beginning of a run.
		__OnRunBegin = undefined;

		/// @ignore
		/// @type {Function|Undefined}
		/// @desc Callback to execute at the end of a run.
		__OnRunEnd = undefined;

		#endregion

	#endregion

	#region PUBLIC

		#region METHODS

		/// @desc Registers or runs the setup callback.
		/// @param {Function} [callback=undefined] Callback to run before a test; omit it to run the registered one.
		/// @return {Struct.CrispyTest} this instance
		static SetUp = function(_callback = undefined)
		{
			if (is_callable(_callback) )
			{
				__SetUp = method(self, _callback);
			}
			else
			{
				if (is_callable(__SetUp) ) __SetUp();
			}

			return self;
		}

		/// @desc Registers or runs the teardown callback.
		/// @param {Function} [callback=undefined] Callback to run after a test; omit it to run the registered one.
		/// @return {Struct.CrispyTest} this instance
		static TearDown = function(_callback = undefined)
		{
			if (is_callable(_callback) )
			{
				__TearDown = method(self, _callback);
			}
			else
			{
				if (is_callable(__TearDown) ) __TearDown();
			}

			return self;
		}

		/// @desc Registers or runs the callback that starts a run.
		/// @param {Function} [callback=undefined] Callback to run at the start of a test; omit it to run the registered one.
		/// @return {Struct.CrispyTest} this instance
		static OnRunBegin = function(_callback = undefined)
		{
			if (is_callable(_callback) )
			{
				__OnRunBegin = method(self, _callback);
			}
			else
			{
				if (is_callable(__OnRunBegin) ) __OnRunBegin();
			}

			return self;
		}

		/// @desc Registers or runs the callback that ends a run.
		/// @param {Function} [callback=undefined] Callback to run at the end of a test; omit it to run the registered one.
		/// @return {Struct.CrispyTest} this instance
		static OnRunEnd = function(_callback = undefined)
		{
			if (is_callable(_callback) )
			{
				__OnRunEnd = method(self, _callback);
			}
			else
			{
				if (is_callable(__OnRunEnd) ) __OnRunEnd();
			}

			return self;
		}

		#endregion

		#region GETTERS

		/// @desc Gets the name of this container.
		/// @return {String} Name of the container.
		static GetName = function()
		{
			return __name;
		}

		#endregion

	#endregion
}
script_execute(CrispyTest);

// Expose the shared variables for inspection in Debug Mode.
if (debug_mode)
{
	global.__crispy_vars = static_get(CrispyTest).vars;
}
