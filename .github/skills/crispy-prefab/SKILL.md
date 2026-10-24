---
name: crispy-prefab
description: 'Guide for integrating and consuming the Crispy prefab API in GameMaker projects. Use when the user asks to implement, call, or interact with the Crispy prefab.'
argument-hint: 'Describe the Crispy test or integration you need'
---

# Crispy: Prefab Integration And Usage

## Role

Act as a GameMaker (GML) expert focused exclusively on **integrating and consuming** the Crispy prefab. The prefab is already installed in the project as a ready-to-use library/asset: do not reimplement it, do not duplicate its constructors, and do not modify its internal code. Everything you write must go through its public API.

## When To Use This Skill

- Adding tests to a project that already imported the Crispy prefab.
- Wiring a runner into an object or a global manager.
- Subscribing to lifecycle callbacks or capturing result output.
- Writing synchronous or asynchronous cases with their assertions.

## Public Surface

These are the only exported symbols (the `#export` lines in `crispy_Config`):

| Kind | Symbols |
| --- | --- |
| Constructors | `CrispyRunner`, `CrispySuite`, `CrispyCase`, `CrispyCaseAsync`, `CrispyLog`, `CrispyTest` |
| Utilities | `crispy_vars()` |
| Macros | `CRISPY_RUN`, `CRISPY_VERSION`, `CRISPY_VERBOSITY`, `CRISPY_TIME_PRECISION`, `CRISPY_LOG_ALERTS`, `CRISPY_LOG_ERRORS`, `CRISPY_FATAL_ERRORS`, `CRISPY_PASS_MSG_SILENT`, `CRISPY_FAIL_MSG_SILENT`, `CRISPY_PASS_MSG_VERBOSE`, `CRISPY_FAIL_MSG_VERBOSE`, `CRISPY_STATUS_OUTPUT_LENGTH`, `CRISPY_SILENCE_PASSING_TESTS_OUTPUT` |

Any member starting with `__` is internal: never read or write it from your project.

## Initialization Sequence

The prefab creates nothing on its own: you build the runner and keep it alive.

### 1. Create Event Of The Controller

```gml
/// @desc Controller that owns the Crispy runner.

runner = new CrispyRunner("gameplay");

var _player_suite = new CrispySuite("player");

_player_suite
	.SetUp(function()
	{
		crispy_vars().player = { hp: 100, alive: true };
	})
	.TearDown(function()
	{
		crispy_vars().player = undefined;
	})
	.AddCase(new CrispyCase("starts with full health", function()
	{
		AssertEqual(crispy_vars().player.hp, 100, "player should start at 100 hp");
	}));

runner
	.AddTestSuite(_player_suite)
	.OnRunBegin(function()
	{
		show_debug_message("Crispy run started.");
	})
	.OnRunEnd(function()
	{
		show_debug_message("Crispy run finished.");
	});

runner.Run();
```

Mandatory order: build runner → build suites → register cases or `Discover` → `AddTestSuite` → `Run`. `Discover` fails if the suite has not been added to the runner yet.

### 2. Step Event Of The Controller

```gml
/// @desc Keeps asynchronous cases moving.

if (runner.IsRunning())
{
	runner.Update();
}
```

`Run()` executes synchronous suites to completion. When async cases exist the runner stays `IsRunning()` and only advances while you call `Update()` every Step.

### 3. No Manual Cleanup

Do not call `runner.TearDown()`: `Run()` does it at the end and prints the report. If you need to release your own resources, use your own `.TearDown(func)` callback.

## Event Subscription And Lifecycle

`SetUp`, `TearDown`, `OnRunBegin` and `OnRunEnd` exist on runner, suite and case, and are **dual-purpose**: with a callable they register the callback and return `self`; with no arguments they run the already registered callback.

| Level | Execution order |
| --- | --- |
| Runner | `SetUp` once (clears logs, starts timer) → per suite: `OnRunBegin` → suite → `OnRunEnd` → final `TearDown` (prints the report) |
| Suite | `SetUp` once → per case: `OnRunBegin` → case → `OnRunEnd` → `TearDown` on close |
| Case | `SetUp` → `OnRunBegin` → test body → `OnRunEnd` → `TearDown` (always, even if the body throws) |

Always register with a callable. Calling `SetUp()` with no arguments **runs** the callback and, on the runner, resets logs and the timer.

## Reading State

| Level | Methods |
| --- | --- |
| Runner | `IsRunning()`, `IsComplete()`, `GetName()` |
| Suite | `IsRunning()`, `IsComplete()`, `GetName()` |
| Case | `IsSkipped()`, `GetLogs()`, `GetDuration()`, `GetClass()`, `GetName()` |
| Async case | `IsAsync()`, `IsRunning()`, `IsComplete()`, `IsFinished()` |

`GetLogs()` returns the case's `CrispyLog` entries; `GetDuration()` is in seconds.

## Capturing Output

`runner.Output()` is overloaded: a string writes one line, a method replaces the sink. This is the public way to subscribe to results, and it must be called before `Run()`.

```gml
runner.Output(function(_message)
{
	show_debug_message("[crispy] " + _message);
	// Push _message into a ds_list, your own log, etc.
});
```

Other public runner utilities: `Hr(str, count)` builds a separator line and `CaptureLogs(input)` aggregates the logs of a case, suite or log into the runner.

## Assertions

They live on `CrispyCase`, take an optional trailing `message`, and return `self` for chaining:

- `AssertEqual(first, second, [message])` - compares `typeof` then `==`
- `AssertNotEqual(first, second, [message])`
- `AssertDeepEqual(first, second, [message])` - recurses through arrays and structs
- `AssertNear(actual, expected, tolerance, [message])`
- `AssertContains(container, value, [message])` - array or string
- `AssertTrue(expr, [message])` / `AssertFalse(expr, [message])`
- `AssertIsNoone(expr, [message])` / `AssertIsNotNoone(expr, [message])`
- `AssertIsUndefined(expr, [message])` / `AssertIsNotUndefined(expr, [message])`
- `AssertRaises(func, [message])` / `AssertRaiseErrorValue(func, value, [message])`
- `AssertDoesNotThrow(func, [message])`
- `Skip()` marks the case as skipped; `ClearLogs()` empties its logs

```gml
function test_player_defaults()
{
	var _player = { hp: 100, alive: true };

	AssertEqual(_player.hp, 100, "hp should be 100")
		.AssertTrue(_player.alive, "player should be alive")
		.AssertContains([ "sword", "shield" ], "sword", "inventory should hold a sword");
}
```

To fail a test, use an assertion, never `throw` inside the body: the case catches the exception and only emits an alert. Use `throw` only in the code under test, and validate it with `AssertRaises` / `AssertRaiseErrorValue`.

## Asynchronous Cases

`CrispyCaseAsync` splits a test into checkpoints that run on Begin Step, Step and End Step.

```gml
var _waits_for_step = new CrispyCaseAsync("waits one step")
	.WaitBeginStep(function()
	{
		return true;
	})
	.WaitStep(function()
	{
		AssertTrue(true, "step arrived");
		return true;
	})
	.Timeout(120, "frames");

var _async_suite = new CrispySuite("async");
_async_suite.AddCase(_waits_for_step);
runner.AddTestSuite(_async_suite);
```

Checkpoint rules:

- `WaitBeginStep(func, [context])`, `WaitStep(func, [context])` and `WaitEndStep(func, [context])` queue callbacks.
- Returning `true` advances; returning `false` waits for the next event of the same kind; any non-boolean value advances immediately.
- `Timeout(value, "frames")` is the default unit; `"seconds"` is the alternative. When it elapses the case fails with a log.
- `Configure(func)` rebuilds the checkpoints on every `Start()`; `Complete()` and `Fail(message)` close early.
- The `o_crispy_async` object ships with the prefab and is persistent: do not delete it, rename it, or strip its Step events.

## Convention-Based Discovery

```gml
function test_inventory_starts_empty()
{
	AssertEqual(array_length(crispy_vars().items), 0, "inventory should start empty");
}

runner.AddTestSuite(_inventory_suite);
runner.Discover(_inventory_suite, "test_inventory_");
```

- Functions must be global scripts, never members of a constructor.
- Name them `test_<component>_<behavior>`; a name containing `_async` creates a `CrispyCaseAsync`, whose body must queue checkpoints and a `Timeout`.
- The target suite must already belong to that runner.
- Each script is discovered once per runner; a second `Discover` with another prefix will not add it again.

## Shared State

`crispy_vars()` returns the static `CrispyTest.vars` struct, shared by **every** runner in the game. Use it so a suite's `SetUp` prepares data its cases consume, and clear the keys in `TearDown` so state does not leak between suites.

```gml
_suite.SetUp(function()
{
	crispy_vars().items = [];
});

_suite.TearDown(function()
{
	crispy_vars().items = undefined;
});
```

## Allowed Configuration

The only supported adjustment is changing the **values** of the macros in the `crispy_Config` asset (that is its configuration surface). The most relevant ones:

- `CRISPY_VERBOSITY` (`0`, `1`, `2`) controls output detail.
- `CRISPY_LOG_ALERTS` / `CRISPY_LOG_ERRORS` enable framework diagnostics.
- `CRISPY_FATAL_ERRORS` (default `true`) closes the game on an internal error.
- `CRISPY_SILENCE_PASSING_TESTS_OUTPUT` and `CRISPY_STATUS_OUTPUT_LENGTH` tune the report.
- `CRISPY_RUN` is only a convention flag: the framework does not read it, so your Step must gate auto-run on it if you want it.

Macros are **compile-time** (`#macro`): they cannot change at runtime, and re-check your values after updating the prefab.

Do not change signatures or logic in the prefab scripts; if you need different behavior, wrap it in your own project.

## Rules

1. Use only public constructors, methods and macros.
2. Do not touch `__` members (`__logs`, `__tests`, `__Output`, `__parent`, ...).
3. Do not call the runner's `TearDown()` manually or reorder the lifecycle.
4. Do not edit the prefab `.gml` files; customization belongs in your project code.
5. Do not substitute assertions with `if` + `show_debug_message`.

## Common Mistakes

- `AddCase` with something that is not a `CrispyCase`/`CrispyCaseAsync`: internal error (fatal by default).
- `Discover` before `AddTestSuite`: error because `__parent` is not the runner.
- Forgetting `runner.Update()`: the async run stays stuck in `IsRunning()`.
- Registering callbacks after `Run()`: they never fire during that run.
- Calling `.SetUp()` with no arguments expecting to "configure": it actually runs the callback.
- An async case without `Timeout`: it can hang forever.

## Verification

1. The runner is created once and reused; `Run()` can be called again.
2. `IsRunning()` returns to `false` and `IsComplete()` to `true` when finished.
3. The report appears in the Output Window with the number of executed cases.
4. Every new case shows in the count; if not, check the `Discover` prefix or the registration in `obj_test`.
