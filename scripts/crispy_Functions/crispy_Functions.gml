/// @desc Returns the shared variables from the CrispyTest constructor.
/// @returns {Struct}
function crispy_vars()
{
	return CrispyTest.vars;
}

/// @ignore
/// @desc Helper function for Crispy to display debug messages
/// @param {Any} msg Text to be displayed in the Output Window
function __crispy_alert(_msg)
{
	if (CRISPY_LOG_ALERTS)
	{
		var _origin = ytrace_origin;
		show_debug_message($"Crispy Alert:: {_origin}:: {_msg}");
	}
}

/// @ignore
/// @desc Helper function for Crispy to display error messages. If CRISPY_FATAL_ERRORS is enabled, the game will also close immediately with an error.
/// @param {Any} msg Text to be displayed in the Output Window
function __crispy_error(_msg)
{
	if (CRISPY_LOG_ERRORS)
	{
		var _origin = ytrace_origin;
		show_debug_message($"Crispy Error:: {_origin}:: {_msg}");
	}

	if (CRISPY_FATAL_ERRORS) { show_error($"Crispy Fatal Error:: {ytrace_origin}:: {_msg}", true); }
}

