/// @desc Base constructor for Crispy test containers.
/// @param {String} name Name of class
function CrispyTest(_name) constructor
{
	/// @desc Shared variables accessible from every Crispy test container.
	/// @type {Struct}
	/// @ignore
	static vars = {};

	/// @ignore
	/// @desc Name of class
	/// @type {String}
	__name = _name;

	/// @ignore
	/// @desc Callback to execute in the setup.
	/// @type {Function|Undefined}
	__SetUp = undefined;

	/// @ignore
	/// @desc Callback to execute in the teardown.
	/// @type {Function|Undefined}
	__TearDown = undefined;

	/// @ignore
	/// @desc Callback to execute at the beginning of run.
	/// @type {Function|Undefined}
	__OnRunBegin = undefined;

	/// @ignore
	/// @desc Callback to execute at the end of run.
	/// @type {Function|Undefined}
	__OnRunEnd = undefined;

	#region METHODS

	/// @desc Get the name of this test
	/// @returns {String} Name of the test
	static GetName = function()
	{
		return __name;
	}

	/// @desc Configures or runs the setup callback.
	/// @param {Function|Undefined} callback Callback to run before a test.
	/// @returns {Struct.CrispyTest} Self for chaining.
	static SetUp = function(_callback = undefined)
	{
		if (is_callable(_callback) )
		{
			__SetUp = method(self, _callback);
		}
		else
		{
			if (is_callable(__SetUp) ) { __SetUp(); }
		}

		return self;
	}

	/// @desc Configures or runs the teardown callback.
	/// @param {Function|Undefined} callback Callback to run after a test.
	/// @returns {Struct.CrispyTest} Self for chaining.
	static TearDown = function(_callback = undefined)
	{
		if (is_callable(_callback) )
		{
			__TearDown = method(self, _callback);
		}
		else
		{
			if (is_callable(__TearDown) ) { __TearDown(); }
		}

		return self;
	}
	
	/// @desc Configures or runs the callback at the start of a run.
	/// @param {Function|Undefined} callback Callback to run at the start of a test.
	/// @returns {Struct.CrispyTest} Self for chaining.
	static OnRunBegin = function(_callback = undefined)
	{
		if (is_callable(_callback) )
		{
			__OnRunBegin = method(self, _callback);
		}
		else
		{
			if (is_callable(__OnRunBegin) ) { __OnRunBegin(); }
		}

		return self;
	}

	/// @desc Configures or runs the callback at the end of a run.
	/// @param {Function|Undefined} callback Callback to run at the end of a test.
	/// @returns {Struct.CrispyTest} Self for chaining.
	static OnRunEnd = function(_callback = undefined)
	{
		if (is_callable(_callback) )
		{
			__OnRunEnd = method(self, _callback);
		}
		else
		{
			if (is_callable(__OnRunEnd) ) { __OnRunEnd(); }
		}

		return self;
	}

	#endregion
}
script_execute(CrispyTest);

// See crispy variables in Debug Mode.
if (debug_mode)
{
	global.__crispy_vars = static_get(CrispyTest).vars;
}