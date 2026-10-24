#export CRISPY_RUN, CRISPY_LOG_ALERTS, CRISPY_LOG_ERRORS, CRISPY_FATAL_ERRORS
#export CRISPY_VERBOSITY, CRISPY_TIME_PRECISION, CRISPY_SILENCE_PASSING_TESTS_OUTPUT
#export CRISPY_PASS_MSG_SILENT, CRISPY_FAIL_MSG_SILENT, CRISPY_PASS_MSG_VERBOSE, CRISPY_FAIL_MSG_VERBOSE
#export CRISPY_STATUS_OUTPUT_LENGTH
#export crispy_vars, CrispyTest, CrispyCase, CrispyCaseAsync, CrispySuite, CrispyRunner, CrispyLog

#region VERSION

/// @ignore Semantic version of the prefab, formatted as [MAJOR.MINOR.PATCH].
#macro CRISPY_VERSION						"2.0.0"

#endregion

#region RUN

/// @ignore Boolean flag that can be used to automatically run tests.
#macro CRISPY_RUN							true

#endregion

#region DIAGNOSTICS

/// @ignore Write library alerts to the debug output. (Default: true)
#macro CRISPY_LOG_ALERTS					false

/// @ignore Write internal library errors to the debug output. (Default: true)
#macro CRISPY_LOG_ERRORS					false

/// @ignore Make internal library errors fatal. (Default: true)
#macro CRISPY_FATAL_ERRORS					true

#endregion

#region OUTPUT

/// @ignore Determines how verbose assertion outputs will be. Acceptable values are 0, 1, or 2. (Default: 2)
#macro CRISPY_VERBOSITY						2

/// @ignore Number of decimal places to round to when outputting time values. (Default: 6)
#macro CRISPY_TIME_PRECISION				6

/// @ignore Output string when an assertion passes silently. (Default: ".")
#macro CRISPY_PASS_MSG_SILENT				"."

/// @ignore Output string when an assertion fails silently. (Default: "F")
#macro CRISPY_FAIL_MSG_SILENT				"F"

/// @ignore Output string when an assertion passes verbosely. (Default: "Ok")
#macro CRISPY_PASS_MSG_VERBOSE				"Ok"

/// @ignore Output string when an assertion fails verbosely. (Default: "Fail")
#macro CRISPY_FAIL_MSG_VERBOSE				"Fail"

/// @ignore Number of characters per line when outputting CrispyCase statuses. (Default: 150)
#macro CRISPY_STATUS_OUTPUT_LENGTH			150

/// @ignore Enables silencing passing test messages in the Output Window. (Default: false)
#macro CRISPY_SILENCE_PASSING_TESTS_OUTPUT	false

#endregion

__crispy_alert("Using Crispy unit testing framework by Brent Frymire and Toto (C.A).");
