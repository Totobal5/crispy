/// @description Testing suite that holds tests
/// @param {String} name - Name of suite
/// @param {Struct} [unpack=undefined] - Struct for crispy_struct_unpack
/// @return {Struct.CrispySuite} description
function CrispySuite(_name, _unpack = undefined) : CrispyTest(_name) constructor 
{
	/// @ignore
	__parent = undefined;

	/// @ignore
	__tests = [];

	/// Run struct unpacker if unpack argument was provided
	/// Stays after all variables are initialized so they may be overwritten
	__crispy_validate_unpack_param(instanceof(self), "", _unpack);

	#region METHODS

	/// @description Adds CrispyCase to array of cases
	/// @param {Struct} test_case - CrispyCase to add
	/// @returns {Struct.CrispySuite} Self for chaining
	static AddCase = function(_test_case)
	{
		if (instanceof(_test_case) != "CrispyCase")
		{
			var _type = !is_undefined(instanceof(_test_case)) ? instanceof(_test_case) : typeof(_test_case);
			__crispy_error($"{instanceof(self)}.AddCase() \"_test_case\" expected an instance of CrispyCase, received {_type}.");
		}
		
		_test_case.__parent = self;
		array_push(__tests, _test_case);

		return self;
	}

	/// @description Event that runs before all tests to set up variables. Can also overwrite __SetUp
	/// @param {Function} [func] - Function to overwrite __SetUp
	/// @return {Struct.CrispySuite} Self for chaining
	static SetUp = function(_func)
	{
		if (!is_undefined(_func))
		{
			var _bound = __crispy_validate_and_bind_method(instanceof(self), "SetUp", _func);
			if (!is_undefined(_bound))
			{
				__SetUp = _bound;
			}
		}
		else
		{
			if (is_method(__SetUp))
			{
				__SetUp();
			}
		}

		return self;
	}

	/// @description Event that runs after all tests to clean up variables. Can also overwrite __TearDown
	/// @param {Function} [func] - Function to overwrite __TearDown
	/// @return {Struct.CrispySuite} Self for chaining
	static TearDown = function(_func)
	{
		if (!is_undefined(_func))
		{
			var _bound = __crispy_validate_and_bind_method(instanceof(self), "TearDown", _func);
			if (!is_undefined(_bound))
			{
				__TearDown = _bound;
			}
		}
		else
		{
			if (is_method(__TearDown))
			{
				__TearDown();
			}
		}

		return self;
	}

	/// @description Runs tests
	/// @returns {Void}
	static Run = function()
	{
		SetUp();

		var i = 0; repeat(array_length(__tests) )
		{
			OnRunBegin();
			
			__tests[i++].Run();
			
			OnRunEnd();
		}

		TearDown();
	}

	/// @returns {String}
	static toString = function()
	{
		return $"<Crispy Suite(\"{__name}\")>";
	}

	#endregion
}