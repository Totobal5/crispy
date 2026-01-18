/// @description Base constructor that test constructors will inherit from
/// @param {String} name - Name of class
function CrispyTest(_name) constructor
{
	/// Shared static struct accessible across all Crispy constructors (Runner, Suite, Case)
	/// Use this to store variables that need to be accessed across test hierarchy
	/// Example: In Suite.SetUp(), set vars.hamburger = new Food(); then access in tests via parent.hamburger
	/// @ignore
	static vars = {};

	/// @ignore
	__name = undefined;
	static SetUp = undefined;
	static TearDown = undefined;

	/// @ignore
	static __SetUp = undefined;
	/// @ignore
	static __TearDown = undefined;
	/// @ignore
	static __OnRunBegin = undefined;
	/// @ignore
	static __OnRunEnd = undefined;

	__struct_unpack = method(self, __crispy_struct_unpack);
	
	__SetName(_name);

	// Getters

	/// Get the name of this test
	/// @returns {String} Name of the test
	static GetName = function()
	{
		return __name;
	}

	// Methods

	/// @ignore
	/// Set name of class object
	/// @param {String} name - Name of the object
	static __SetName = function(_name)
	{
		if (!is_string(_name))
		{
			__crispy_error($"{instanceof(self)}.__SetName() \"name\" expected a string, received {typeof(_name)}.");
		}
		__name = _name;
	}

	/// Event to be called at the beginning of run
	/// @param {Function} [func] - Method to override __OnRunBegin with
	static OnRunBegin = function()
	{
		if (argument_count > 0)
		{
			var _func = argument[0];
			if (is_method(_func))
			{
				__OnRunBegin = method(self, _func);
			}
			else
			{
				__crispy_error($"{instanceof(self)}.OnRunBegin() \"func\" expected a function, received {typeof(_func)}.");
			}
		}
		else
		{
			if (is_method(__OnRunBegin))
			{
				__OnRunBegin();
			}
		}
	}

	/// Event to be called at the end of run
	/// @param {Function} [func] - Method to override __OnRunEnd with
	static OnRunEnd = function()
	{
		if (argument_count > 0)
		{
			var _func = argument[0];
			if (is_method(_func))
			{
				__OnRunEnd = method(self, _func);
			}
			else
			{
				__crispy_error($"{instanceof(self)}.OnRunEnd() \"func\" expected a function, received {typeof(_func)}.");
			}
		}
		else
		{
			if (is_method(__OnRunEnd))
			{
				__OnRunEnd();
			}
		}
	}
}