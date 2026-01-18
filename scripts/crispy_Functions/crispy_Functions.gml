/// Helper function for Crispy to display debug messages
/// @param {Any} msg - Text to be displayed in the Output Window
function __crispy_alert(msg)
{
	if (CRISPY_DEBUG) show_debug_message(CRISPY_NAME + $"ALERT: {msg}");
}

/// Helper function for Crispy to display error messages
/// @param {Any} msg - Text to be displayed in the Output Window
function __crispy_error(msg)
{
	if (CRISPY_DEBUG) show_debug_message(CRISPY_NAME + $"ERROR: {msg}");
}

/// Mixin function that extends structs with the struct_unpack() method
function __crispy_mixin_struct_unpack()
{
	struct_unpack = method(self, __crispy_struct_unpack);
}

/// Helper function for structs that replaces variable values with given source struct values
/// @param {Struct} unpack - Struct used to replace existing values with
/// @param {Bool} [name_must_exist=true] - Boolean flag that prevents new variable names from being added to destination struct if variable name does not already exist
/// @ignore
function __crispy_struct_unpack(_unpack, _name_must_exist = true)
{
	if (!is_struct(_unpack))
	{
		__crispy_error("__crispy_struct_unpack() \"unpack\" expected a struct, received " + typeof(_unpack) + ".");
	}
	if (!is_bool(_name_must_exist))
	{
		__crispy_error("__crispy_struct_unpack() \"name_must_exist\" expected a boolean, received " + typeof(_name_must_exist) + ".");
	}

	var _names = variable_struct_get_names(_unpack);
	var _len = array_length(_names);
	var i = 0;
	repeat (_len)
	{
		var _name = _names[i];
		if (!CRISPY_STRUCT_UNPACK_ALLOW_DUNDER && __crispy_is_internal_variable(_name))
		{
			if (CRISPY_DEBUG)
			{
				__crispy_alert("Variable names beginning and ending in double underscores are reserved for the framework. Skip unpacking struct name: " + _name);
			}
			++i;
			continue;
		}
		var _value = variable_struct_get(_unpack, _name);
		if (_name_must_exist)
		{
			// Feather disable once GM1041
			if (!variable_struct_exists(self, _name))
			{
				if (CRISPY_DEBUG)
				{
					__crispy_alert("Variable name \"" + _name + "\" not found in struct, skip writing variable name.");
				}
				++i;
				continue;
			}
		}
		// Feather disable once GM1041
		variable_struct_set(self, _name, _value);
		++i;
	}
}

/// Helper function that returns whether or not a given variable name follows internal variable naming convention
/// @param {String} name - Name of variable to check
/// @returns {Bool} Whether the given string follows internal variable naming convention
function __crispy_is_internal_variable(_name)
{
	if (!is_string(_name))
	{
		__crispy_error("__crispy_is_internal_variable() \"name\" expected a string, received " + typeof(_name) + ".");
	}

	var _len = string_length(_name);
	if (_len > 4 && string_copy(_name, 1, 2) == "__" && string_copy(_name, _len - 1, _len) == "__")
	{
		return true;
	}

	return false;
}
