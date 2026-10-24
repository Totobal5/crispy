/// @desc Returns the shared variables from the CrispyTest constructor.
/// @return {Struct} Shared variables struct.
function crispy_vars()
{
	return CrispyTest.vars;
}

/// @ignore
/// @desc Resolves the class name of a value, falling back to its type when it is not a struct.
/// @param {Any} value Value to describe.
/// @return {String} Class name of the value, or its type.
function __crispy_type(_value)
{
	if (!is_struct(_value) ) return typeof(_value);

	var _class = instanceof(_value);

	return is_undefined(_class) ? typeof(_value) : _class;
}

/// @ignore
/// @desc Writes a framework alert to the Output Window when alerts are enabled.
/// @param {Any} msg Text to be displayed in the Output Window.
function __crispy_alert(_msg)
{
	if (!CRISPY_LOG_ALERTS) return;

	var _origin = ytrace_origin;
	// Prefab imports prefix the trace origin with the package id.
	_origin = string_replace_all(_origin, "cyou_tobalsea_crispy_1_0_1___", "tobalsea_crispy_");

	show_debug_message($"Crispy Alert:: {_origin}:: {_msg}");
}

/// @ignore
/// @desc Writes a framework error to the Output Window and closes the game when errors are fatal.
/// @param {Any} msg Text to be displayed in the Output Window.
function __crispy_error(_msg)
{
	if (!CRISPY_LOG_ERRORS && !CRISPY_FATAL_ERRORS) return;

	var _origin = ytrace_origin;
	// Prefab imports prefix the trace origin with the package id.
	_origin = string_replace_all(_origin, "cyou_tobalsea_crispy_1_0_1___", "tobalsea_crispy_");

	show_debug_message($"Crispy Error:: {_origin}:: {_msg}");

	if (CRISPY_FATAL_ERRORS)
	{
		show_error($"Crispy Fatal Error:: {_origin}:: {_msg}", true);
	}
}
