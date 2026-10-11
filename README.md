# Crispy

`@toto/Crispy` is a unit testing framework for GameMaker projects. It organizes tests into runners, suites, and cases, supports automatic discovery, and can run asynchronous tests across GameMaker step events.

## What It Provides

- `CrispyRunner` to execute suites and collect their results.
- `CrispySuite` to group related test cases and define suite callbacks.
- `CrispyCase` with assertions for values, errors, arrays, strings, and deep equality.
- `CrispyCaseAsync` for tests driven by Begin Step, Step, and End Step.
- `CrispyRunner.Discover()` for convention-based test discovery.
- `crispy_vars()` for state shared by the test hierarchy.
- Configurable output, verbosity, timing, and error behavior.

## Quick Start

Create a runner, add a suite and one or more cases, then run the runner:

```gml
var runner = new CrispyRunner("gameplay");
var suite = new CrispySuite("player");

suite.AddCase(new CrispyCase("starts with health", function()
{
   var health = 100;
   AssertEqual(health, 100);
}));

runner.AddTestSuite(suite);
runner.Run();
```

Crispy writes the result summary to the Output window. Cases can contain multiple chained assertions:

```gml
function test_player_defaults()
{
   var player = {
      health: 100,
      alive: true,
   };

   AssertEqual(player.health, 100)
      .AssertTrue(player.alive);
}
```

## Suites And Callbacks

A suite runs `SetUp()` before its cases and `TearDown()` after they finish. `OnRunBegin()` and `OnRunEnd()` run around each case in the suite.

```gml
var suite = new CrispySuite("inventory")
   .SetUp(function()
   {
      crispy_vars().items = [];
   })
   .TearDown(function()
   {
      crispy_vars().items = undefined;
   });
```

`crispy_vars()` returns the shared struct used by runners, suites, and cases. Use it for state that a suite prepares and its cases consume.

## Test Discovery

Define global functions with a shared prefix, add the target suite to the runner, then discover the functions:

```gml
function test_inventory_starts_empty()
{
   AssertEqual(array_length(crispy_vars().items), 0);
}

var runner = new CrispyRunner("gameplay");
var suite = new CrispySuite("inventory");

runner.AddTestSuite(suite);
runner.Discover(suite, "test_inventory_");
runner.Run();
```

Each discovered function becomes a `CrispyCase`. A discovered function whose name contains `_async` becomes a `CrispyCaseAsync`.

## Assertions

All assertions accept an optional final message and return the case for chaining.

- `AssertEqual(first, second, [message])`
- `AssertNotEqual(first, second, [message])`
- `AssertDeepEqual(first, second, [message])`
- `AssertNear(actual, expected, tolerance, [message])`
- `AssertContains(container, value, [message])`
- `AssertTrue(expr, [message])` and `AssertFalse(expr, [message])`
- `AssertIsNoone(expr, [message])` and `AssertIsNotNoone(expr, [message])`
- `AssertIsUndefined(expr, [message])` and `AssertIsNotUndefined(expr, [message])`
- `AssertRaises(callback, [message])`
- `AssertRaiseErrorValue(callback, value, [message])`
- `AssertDoesNotThrow(callback, [message])`

## Asynchronous Tests

Use `CrispyCaseAsync` to wait for Begin Step, Step, or End Step. A callback that returns `true` advances to the next checkpoint. A callback that returns `false` waits and runs again on the next matching event; any non-boolean return value advances immediately.

```gml
var async_case = new CrispyCaseAsync("waits for a step")
   .WaitStep(function()
   {
      AssertTrue(true);
      return true;
   })
   .Timeout(120, "frames");

var suite = new CrispySuite("async");
suite.AddCase(async_case);

var runner = new CrispyRunner("gameplay");
runner.AddTestSuite(suite);
runner.Run();
```

Call `runner.Update()` from a Step event while asynchronous tests are active:

```gml
runner.Update();
```

`Timeout(value, "frames")` is the default. Use `Timeout(value, "seconds")` for a time-based limit.

## Configuration

Set the exported macros in `crispy_Config` before running tests.

| Macro | Default | Effect |
| --- | --- | --- |
| `CRISPY_RUN` | `true` | Flag available to control automatic test execution. |
| `CRISPY_LOG_ALERTS` | `false` | Writes Crispy alerts to the Output window. |
| `CRISPY_LOG_ERRORS` | `false` | Writes internal Crispy errors to the Output window. |
| `CRISPY_FATAL_ERRORS` | `true` | Stops execution when Crispy reports an internal error. |
| `CRISPY_VERBOSITY` | `2` | Controls log detail: `0`, `1`, or `2`. |
| `CRISPY_TIME_PRECISION` | `6` | Decimal places used for total run time. |
| `CRISPY_PASS_MSG_SILENT` | `"."` | Text used for a passing assertion at verbosity `0`. |
| `CRISPY_FAIL_MSG_SILENT` | `"F"` | Text used for a failing assertion at verbosity `0`. |
| `CRISPY_PASS_MSG_VERBOSE` | `"Ok"` | Text used for a passing test at verbose output. |
| `CRISPY_FAIL_MSG_VERBOSE` | `"Fail"` | Text used for a failing test at verbose output. |
| `CRISPY_SILENCE_PASSING_TESTS_OUTPUT` | `false` | Suppresses individual passing result messages. |
| `CRISPY_STATUS_OUTPUT_LENGTH` | `150` | Number of compact status characters per output row. Set to `0` to hide them. |

## License

[MIT License](LICENSE)
