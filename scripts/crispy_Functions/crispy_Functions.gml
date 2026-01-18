/**
 * Helper function for Crispy to display its debug messages
 * @param {Any} [_message] - Text to be displayed in the Output Window
 */
function __crispy_alert(_msg)
{
	if (CRISPY_DEBUG) show_debug_message(CRISPY_NAME + $"ALERT: {_msg}");
}

/**
 * Helper function for Crispy to display its debug messages
 * @param {Any} [_message] - Text to be displayed in the Output Window
 */
function __crispy_error(_msg)
{
	if (CRISPY_DEBUG) show_debug_message(CRISPY_NAME + $"ERROR: {_msg}");
}


/**
 * Returns the current time in micro-seconds since the project started running
 * @returns {Real} Time that your game has been running in milliseconds
 */
function crispyGetTime() 
{
	return get_timer();
}

/**
 * Returns the difference between two times
 * @function crispyGetTimeDiff
 * @param {Real} _start_time - Starting time in milliseconds
 * @param {Real} _stop_time - Stopping time in milliseconds
 * @returns {Real} Difference between start_time and stop_time
 */
function crispyGetTimeDiff(_start_time, _stop_time) 
{
	if !is_real(_start_time) 
    {
		throw("crispyGetTimeDiff() \"_start_time\" expected a real number, received " + typeof(_start_time) + ".");
	}
    
	if !is_real(_stop_time)
    {
		throw("crispyGetTimeDiff() \"_stop_time\" expected a real number, received " + typeof(_stop_time) + ".");
	}
    
	return _stop_time - _start_time;
}

/**
 * Helper function for Crispy that returns whether or not a given variable name follows internal variable
 * 		naming convention
 * @param {String} _name - Name of variable to check
 * @returns {Bool} Whether the given string follows internal variable naming convention
 */
function crispyIsInternalVariable(_name)
{
	if !is_string(_name) {
		throw("crispyIsInternalVariable() \"_name\" expected a string, received " + typeof(_name) + ".");
	}
	
	var _len = string_length(_name);
	if _len > 4 && string_copy(_name, 1, 2) == "__" && string_copy(_name, _len - 1, _len) == "__" {
		return true;
	}
    
	return false;
}

/**
 * Mixin function that extends structs to have the crispyStructUnpack() function
 */
function crispyMixinStructUnpack() {
	crispyStructUnpack = method(self, __crispyStructUnpack);
}

/**
 * Converts the given time milliseconds to seconds as a string
 * @param {Real} _time - Time in milliseconds
 * @returns {String} time in seconds with CRISPY_TIME_PRECISION number
 * 		of decimal points as a string
 */
function crispyTimeConvert(_time) 
{
	if !is_real(_time) 
    {
		throw("crispyTimeConvert() \"_time\" expected a real number, received " + typeof(_time) + ".");
	}
    
	return string_format(_time / 1000000, 0, CRISPY_TIME_PRECISION);
}

/**
 * Helper function for structs that will replace a destination's
 * 		variable name values with the given source's variable name values
 * @param {Struct} _unpack - Struct used to replace existing values with
 * @param {Bool} [_name_must_exist=true] - Boolean flag that prevents
 * 		new variable names from being added to the destination struct if
 * 		the variable name does not already exist
 * @ignore
 */
function __crispyStructUnpack(_unpack, _name_must_exist=true)
{
	if !is_struct(_unpack) {
		throw("crispyStructUnpack() \"_unpack\" expected a struct, received " + typeof(_unpack) + ".");
	}
	if !is_bool(_name_must_exist) {
		throw("crispyStructUnpack() \"_name_must_exist\" expected a boolean, received " + typeof(_name_must_exist) + ".");
	}

	var _names = variable_struct_get_names(_unpack);
	var _len = array_length(_names);
	var i = 0;
	repeat (_len) {
		var _name = _names[i];
		if !CRISPY_STRUCT_UNPACK_ALLOW_DUNDER && crispyIsInternalVariable(_name) {
			if CRISPY_DEBUG {
				crispyDebugMessage("Variable names beginning and ending in double underscores are reserved for the framework. Skip unpacking struct name: " + _name);
			}
			++i;
			continue;
		}
		var _value = variable_struct_get(_unpack, _name);
		if _name_must_exist {
			// Feather disable once GM1041
			if !variable_struct_exists(self, _name) {
				if CRISPY_DEBUG {
					crispyDebugMessage("Variable name \"" + _name + "\" not found in struct, skip writing variable name.");
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
