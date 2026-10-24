# Crispy Testing Framework - AI Agent Guide

## Overview
Crispy is a unit-testing framework for GameMaker (GML), shipped as the prefab `@toto/crispy`. It organizes tests as Runners → Suites → Cases and runs them inside the GameMaker runtime — there is no external test runner. Framework code lives in `scripts/`; demo scripts and self-tests sit beside it and are exported with the package.

## Build, Run, And Test

There is no CLI build, test command, or linter in this repository. Everything runs through the GameMaker IDE.

| Task | How |
| --- | --- |
| Open the project | `crispy.yyp` (IDE `2026.100.0.1171`; the package declares LTS `>=2026.100.0`) |
| Run the whole suite | Press **F5**. `rm_test` contains `obj_test`, which builds the runner in Create and runs it in Step. |
| Re-run / clear | Press **R** to re-run, **C** to clear results while the game runs. |
| Run one test or suite | No filter flag exists. Narrow the prefix in `runner.Discover(suite, "test_x_")`, or comment out the other `AddTestSuite`/`Discover` pairs in `objects/obj_test/Create_0.gml`, then press F5. |
| Read results | Output Window (`show_debug_message`) plus the on-screen list drawn by `objects/obj_test/Draw_64.gml`. |
| Release | Push a semver tag (`v2.2.4`, `2.2.4`, `v2.2`). `.github/workflows/release.yml` builds the `.yymps` with `tinkerer-red/release-actions` and generates notes from commits and issues. |

`objects/obj_test/Create_0.gml` is the single wiring point: it registers four suites, each bound to a discovery prefix (`test_gui_box`, `test_hamburger_`, `test_food_`, `test_crispy_`). A test script matching no registered prefix never runs. The Step event is also gated by the `CRISPY_RUN` macro.

## Architecture

### Core Test Hierarchy
- `CrispyTest` (`scripts/crispy_Test/crispy_Test.gml`) — base constructor. Holds `__name`, the four lifecycle callbacks, and the shared `static vars` struct.
- `CrispyRunner` (`scripts/crispy_Runner/crispy_Runner.gml`) — owns suites, times the run, aggregates logs, and prints the report.
- `CrispySuite` (`scripts/crispy_Suite/crispy_Suite.gml`) — groups cases, runs suite-level `SetUp`/`TearDown`, coordinates async cases.
- `CrispyCase` (`scripts/crispy_Case/crispy_Case.gml`) — runs one test callback and records one `CrispyLog` per assertion.
- `CrispyCaseAsync` (`scripts/Crispy_Case_Async/Crispy_Case_Async.gml`) — extends `CrispyCase`; runs checkpoint callbacks across Begin Step / Step / End Step.
- `CrispyLog` (`scripts/crispy_Log/crispy_Log.gml`) — one immutable result record; formats itself per `CRISPY_VERBOSITY`.

### Execution Model
`runner.Run()` starts the run and immediately drives `__AdvanceSuites()`. Synchronous suites finish inside that call; an async case leaves the suite `IsRunning()`, so the host must call `runner.Update()` every Step while `runner.IsRunning()` is true.

Per-case order is `SetUp` → `OnRunBegin` → test body → `OnRunEnd` → `TearDown`. `CrispyCase.Run()` wraps the body in `try/catch` and still runs `TearDown` on error. For a suite, `OnRunBegin`/`OnRunEnd` bracket each case; an async case sets `__suite_on_run_end_pending`, so the suite's `OnRunEnd` is deferred until that case completes and `Suite.Update()` calls `__FinalizeRun()` once nothing is pending.

`CrispyCaseAsync` delegates events through a persistent host instance of `o_crispy_async` (`__CreateHost`), which stores the case in `async_case` and caches `variable_get_hash` values for `OnBeginStep`/`OnStep`/`OnEndStep`. Removing that object, renaming it, or making it non-persistent breaks async tests.

### Async Checkpoints
`WaitBeginStep` / `WaitStep` / `WaitEndStep` queue `{ event_name, callback, context }` entries. On the matching event the next checkpoint runs: returning `true` advances, returning `false` waits for the next matching event, and any non-boolean return advances immediately. `Timeout(value, unit)` accepts `"frames"` (default) or `"seconds"` and is checked after each event; a timeout calls `Fail(...)`, which adds a failing log and completes the case. `Configure(func)` and discovery both set `__rebuild_on_start`, so the builder runs again on every `Start()`; `Complete()` and `Fail()` finish early.

### Discovery Mechanics
`runner.Discover(suite, prefix)` walks script asset IDs from `100000` upward, stops after `2048` consecutive missing IDs, skips `_gml_Object_` and `_gml_GlobalScript_` entries, and caches the scan in `__discovered`. Consequences:
- The target suite must already be added to that runner (`__parent` is checked).
- Each script is claimed once per runner; a later `Discover` with a different prefix will not re-add it.
- A name containing `_async` becomes a `CrispyCaseAsync`; everything else becomes a `CrispyCase`.
- Passing no suite creates a temporary `"__discovered_test_suite__"`, deleted if it stays empty.

### Log Aggregation And Output
Assertions append to the case's `__logs`; the runner never sees them individually. `CrispyRunner.CaptureLogs()` collapses a case into a single case-level `CrispyLog` whose `__helper_text` lists every failed assertion — the summary therefore counts cases, not assertions.

`runner.Output(value)` is overloaded: a string is written, a method replaces the internal output sink. `obj_test` registers a callback with `runner.Output(...)` so output is mirrored into a `ds_list` for the on-screen view; the callback captures the list in a local because the runner rebinds the callback to itself.

### Packaging And Prefab
- `crispy_Config.gml` holds every macro plus two `#export` lines (macros and constructors). New public API must be added to those lines.
- `prefab_assets.json` lists the assets exported in the `.yymps` (`"export": 2`). A new framework script must be added there or it will not ship.
- `package/package.json` (and the duplicate root `package.json`) describe the prefab; `package/*.yymps` are build artifacts. Keep `CRISPY_VERSION` and the manifest versions aligned.
- `crispy.yyp` forces the `cyou.tobalsea.ytrace-1.0.1` prefab. `__crispy_alert`/`__crispy_error` read `ytrace_origin` and strip the `cyou_tobalsea_crispy_1_0_1___` prefix from trace text.

### Writing Discoverable Tests
Define test functions at global script scope (never inside a constructor) with a shared prefix, register a suite, then discover it:
```gml
function test_hamburger_has_pickles()
{
	AssertTrue(CrispyTest.vars.hamburger.HasIngredient("pickles"), "You forgot the pickles!");
}

runner.AddTestSuite(hamburger_suite);
runner.Discover(hamburger_suite, "test_hamburger_");
```
- Discovered functions are wrapped in `CrispyCase`; names containing `_async` become `CrispyCaseAsync` and must queue checkpoints (`WaitStep`, `Timeout`, ...).
- See `scripts/example_of_discoverable_tests/` (including `test_discoverable_async_function`), `scripts/food_tests/`, `scripts/gui_tests/`.

## Key Conventions

### Naming Patterns
- **Constructor classes**: `PascalCase` (e.g., `CrispySuite`, `CrispyCase`, `CrispyRunner`)
- **Variables**: `snake_case` (e.g., `test_count`, `is_running`)
- **Internal variables**: `__snake_case` (e.g., `__logs`, `__test`, `__class`) - not part of the public surface; never read or write them from test code
- **Shared state accessor**: `crispy_vars()` returns the same struct as `CrispyTest.vars`
- **Test functions**: `test_<component>_<behavior>()` for discoverability
- **Functions**: `snake_case` (e.g., `crispy_vars()`); every method of a constructor is `PascalCase` (e.g., `GetWidth()`, `IsGlutenFree()`)
- **Internal library functions**: `__snake_case` (e.g., `__crispy_error()`, `__crispy_alert()`)
- **All Crispy framework functions**: prefixed with `crispy_` or `__crispy_`

### Method Naming Convention
- **All methods**: `PascalCase` (e.g., `GetClass()`, `AddLog()`, `AssertEqual()`, `SetUp()`, `Run()`, `OnRunBegin()`)
- **Private/internal methods**: `__PascalCase()` (e.g., `__Discover()`, `__SetUp()` - internal use only, not for external calling)
- **Exception**: `toString()` must be `camelCase` (GameMaker struct convention for string conversion override)

### Commit Convention
All commits follow a simple, direct convention in English:
- **Format**: `<type>: <short description>`
- **Types**: `refactor`, `fix`, `feat`, `docs`, `test`, `chore`
- **Style**: Short, simple, no fluff or hype - direct and honest
- **Examples**:
  - `refactor: end refactor and include meta-tests.`
  - `fix: resolve assertion chaining return value.`
  - `feat: add OnRunBegin and OnRunEnd callbacks.`
  - `docs: update naming conventions documentation.`
  - `test: add validation for callback behavior.`
  - `chore: remove unused variable declarations.`

**Key principles:**
- Keep commit messages under 50 characters when possible
- Use lowercase (except for code references)
- No periods unless the message is a complete sentence
- Be specific about what changed, not why
- One logical change per commit

### Assertion Methods (all on CrispyCase)
All assertions accept an optional final `message` parameter and return `self`:
- `AssertEqual(first, second, [message])` - Compares `typeof` first, then `==`
- `AssertNotEqual(first, second, [message])`
- `AssertDeepEqual(first, second, [message])` - Recursive equality for arrays and structs
- `AssertNear(actual, expected, tolerance, [message])`
- `AssertContains(container, value, [message])` - Array or string
- `AssertTrue(expr, [message])` / `AssertFalse(expr, [message])`
- `AssertIsNoone(expr, [message])` / `AssertIsNotNoone(expr, [message])`
- `AssertIsUndefined(expr, [message])` / `AssertIsNotUndefined(expr, [message])`
- `AssertRaises(func, [message])` - Expects func to throw error
- `AssertRaiseErrorValue(func, value, [message])` - Validates exact error message
- `AssertDoesNotThrow(func, [message])`
- `Skip()` - Marks the case skipped; `Run()` returns immediately
- Queries: `GetLogs()`, `GetDuration()`, `GetClass()`, `IsSkipped()`

### Method Chaining Pattern
All core CrispyCase methods now support **method chaining** by returning `self`:
- `SetUp([func])` - Returns `self`
- `TearDown([func])` - Returns `self`
- `AddLog(log)` - Returns `self`
- All assertion methods - Return `self`
- `ClearLogs()` - Returns `self`

This enables writing multiple assertions in a fluent style:
```gml
function test_multiple_assertions() {
    var _value = 42;
    
    my_case
        .AssertEqual(_value, 42, "Value should be 42")
        .AssertTrue(_value > 0, "Value should be positive")
        .AssertNotEqual(_value, 0, "Value should not be zero");
}
```

**Lifecycle Methods also support chaining:**
```gml
function test_with_setup_teardown() {
    var _case = new CrispyCase("example", function() {
        AssertTrue(true, "This passes");
    });
    
    _case
        .SetUp(function() {
            show_debug_message("Setting up test...");
        })
        .TearDown(function() {
            show_debug_message("Tearing down test...");
        })
        .Run();
}
```

**Benefits:**
- Reduces boilerplate code by eliminating repeated variable names
- Improves readability by showing assertion flow visually
- Optional - single assertions still work without chaining
- Maintains API backward compatibility

### Shared State Pattern
All Crispy constructors inherit `static vars = {}` from CrispyTest base class:
- **Purpose**: Share variables across test hierarchy (Runner → Suite → Case)
- **Access pattern**: Store in Suite's SetUp, access in tests via `CrispyTest.vars`
- **Example**:
```gml
// In Suite.SetUp():
hamburger_suite.SetUp(function() {
    CrispyTest.vars.hamburger = new Food("hamburger", ingredients); // Stored in static vars
});

// In test function:
function test_hamburger_top_bun() {
    AssertEqual(CrispyTest.vars.hamburger.GetIngredients()[0].GetName(), "bun"); // Access via CrispyTest.vars
}
```
- `CrispyTest.vars` is a shared static struct accessible from all Crispy test contexts
- This allows tests to access setup variables without global scope pollution

## Configuration
All config in `scripts/crispy_Config/crispy_Config.gml` using `#macro` (values aligned with tabs, each documented with `/// @ignore`):
- `CRISPY_VERSION` - Framework version, e.g. `"2.0.0"`
- `CRISPY_RUN` - Auto-run flag read by the test object
- `CRISPY_VERBOSITY` (0-2) - Controls assertion output detail
- `CRISPY_LOG_ALERTS` - Write framework alerts to the output
- `CRISPY_LOG_ERRORS` - Write framework errors to the output
- `CRISPY_FATAL_ERRORS` - Make framework errors fatal (`show_error(..., true)`)
- `CRISPY_TIME_PRECISION` - Decimal places for total run time
- `CRISPY_PASS_MSG_SILENT` / `CRISPY_FAIL_MSG_SILENT` - Per-test characters at verbosity `0`
- `CRISPY_PASS_MSG_VERBOSE` / `CRISPY_FAIL_MSG_VERBOSE` - Per-test text at verbosity `1`/`2`
- `CRISPY_SILENCE_PASSING_TESTS_OUTPUT` - Suppress passing test messages
- `CRISPY_STATUS_OUTPUT_LENGTH` - Characters per status row (`0` hides the rows)

## Shared Helper Functions (crispy_Functions.gml)

### Utility Helpers
- `crispy_vars()` - Returns `CrispyTest.vars`
- `__crispy_alert(message)` - Non-fatal diagnostic, gated by `CRISPY_LOG_ALERTS`; prefixes `ytrace_origin`
- `__crispy_error(message)` - Contract violation, gated by `CRISPY_LOG_ERRORS || CRISPY_FATAL_ERRORS`; fatal when `CRISPY_FATAL_ERRORS`

Validation pattern used throughout the framework: check the value (`is_instanceof`, `is_callable`, `typeof`), call `__crispy_error($"Type.Method() 'arg' expected ..., received {typeof(arg)}.")`, then `return self`. Never throw from framework code; test fixtures (e.g. `Food`) do throw so `AssertRaises` can observe it.

## Typical Workflow

### JSDoc Convention
- **Parameter names in JSDoc**: Use the name WITHOUT the underscore prefix
  - Example: `@param {String} name` (not `@param {String} _name`)
  - The underscore is an implementation detail; JSDoc should document the logical name
  - Use `@desc` to clarify purpose, `@ignore` as the first tag on internal members
  - GameMaker doc types: `Real`, `Bool`, `String`, `Struct`, `Method`, `Any`, `Real|Undefined`
  - The framework uses `@return`; match the file you edit.

### Adding A Test Script
1. Create `scripts/<feature>_tests/<feature>_tests.gml` through the IDE (folder, `.yy` and `.gml` names must match).
2. Register a suite and prefix in `objects/obj_test/Create_0.gml`:
```gml
feature_suite = new CrispySuite("feature_suite");
runner.AddTestSuite(feature_suite);
runner.Discover(feature_suite, "test_feature_");
```
3. Press F5 and confirm the case count in the summary changed.

### Creating Tests
1. Create test functions with `test_` prefix or manually create CrispyCase instances:
```gml
function test_hamburger_has_pickles()
{
	AssertTrue(CrispyTest.vars.hamburger.HasIngredient("pickles"), "Hamburger should have pickles");
}
```

2. Set up runner and suite in object Create event:
```gml
runner = new CrispyRunner("runner");
suite = new CrispySuite("my_suite");
suite.SetUp(function() { /* setup code */ });
runner.AddTestSuite(suite);
runner.Discover(suite, "test_hamburger_");
```

3. Run tests (typically in Step or keyboard event), then pump async work:
```gml
if (can_run_tests)
{
	runner.Run();
	can_run_tests = false;
}
else if (runner.IsRunning())
{
	runner.Update();
}
```

### Adding New Assertion Types
1. Add static method to `CrispyCase` in `scripts/crispy_Case/crispy_Case.gml`.
2. Validate arguments with `is_*` / `typeof` checks and `__crispy_error` (`argument_count` is not used).
3. Create `new CrispyLog(self, { __pass: ..., __msg: ..., __helper_text: ... })`.
4. Record it with `AddLog(...)` and `return self` so chaining keeps working.
5. Add a `test_crispy_case_*` self-test in `scripts/crispy_Self_Test/crispy_Self_Test.gml`.

### Adding Public API
1. Implement the member on the relevant constructor in `scripts/`.
2. Add the symbol to the matching `#export` line in `scripts/crispy_Config/crispy_Config.gml`.
3. If you created a new script asset, add it to `prefab_assets.json` and to `crispy.yyp`.
4. Cover the behavior with a `test_crispy_*` self-test.

## GameMaker-Specific Notes

### File Structure
- `.yy`, `.yyp` and `crispy.resource_order` are IDE-generated JSON. Create assets in the IDE so these stay consistent; hand-edit only to register a resource, and keep the trailing-comma style the generator emits.
- `.gml` files hold the code and are edited directly.
- `scripts/<name>/` holds one `.gml` plus its `.yy`; folder, `.yy` and `.gml` names must be identical.
- `objects/<name>/` holds event files named after the event (`Create_0.gml`, `Step_0.gml`, `Draw_64.gml`).

### GML Language Quirks
- `instanceof(struct)` returns the constructor name as a string, and prefab imports prefix those names (`cyou_tobalsea_crispy_1_0_1___...`). Prefer `is_instanceof(value, Constructor)` for type checks so prefab renaming does not break them.
- `method(context, func)` binds a function to a context (like JavaScript `.bind()`); the framework binds every user callback with `method(self, _func)`.
- Use named parameters with default values when an optional callback or message is supported.
- `show_error(msg, abort)` exists, but Crispy routes internal errors through `__crispy_error()`.
- Crispy framework uses `__crispy_error()` and `__crispy_alert()` for internal logging controlled by the config macros.
- `repeat(n) { }` is idiomatic for fixed iterations, e.g., `repeat(array_length(_names)) { ... }`
- String interpolation: `$"text {variable}"` used throughout Crispy for error messages and output
- Use `struct_*` functions instead of `variable_struct_*` functions for better performance and clarity
- Use `exit;` to break out of functions for YYC compatibility
- `typeof` returns `"method"`, `"struct"`, `"array"`, `"bool"`, `"real"`, `"string"`, `"undefined"`, `"number"` - JSON-style names, not GameMaker doc types.

### Code Formatting
- Tabs, Allman braces, semicolons on every statement, and a space between nested closing parens (`) )`, never `))` - see `.github/skills/gml-code-conventions/SKILL.md`.
- **Blank lines after closing braces**: Always add a blank line after `}` before the next variable declaration or statement
  - Example: After `continue;` in if-block, add blank line before `var _value = ...`
- Long calls put each argument on its own line; fluent chains break before the dot.
- When a file already uses a different style, match that file rather than reformatting it.

### Testing Pattern
- Tests run in GameMaker runtime (not external test runner)
- Output via `show_debug_message()` to Output Window
- Visual feedback can be added via Draw events (see `objects/obj_test/Draw_64.gml`)

## Common Pitfalls
- Don't use assertion methods outside a `CrispyCase` - they log to that case's internal array
- Discoverable test functions must be global script functions (not inside constructors)
- `AddTestSuite` must run before `Discover` for the same suite; the runner validates `__parent`
- Forgetting `runner.Update()` leaves async runs stuck: `runner.IsRunning()` stays true forever
- `CaptureLogs` reports one log per case, not per assertion; the summary counts cases
- `o_crispy_async` must remain persistent and keep its three Step events, or async cases never advance
- All methods use `PascalCase` including lifecycle methods: use `SetUp()` and `TearDown()` consistently
- Callbacks are optional; calling a lifecycle method without a registered callback is a no-op.
- GameMaker uses 0-based arrays but 1-based strings (`string_copy` starts at 1)

## Example Files
- Runner wiring and on-screen output: `objects/obj_test/` (`Create_0.gml`, `Step_0.gml`, `Draw_64.gml`)
- Discovery examples: `scripts/food_tests/`, `scripts/hamburger_tests/`, `scripts/gui_tests/`, `scripts/example_of_discoverable_tests/`
- Async discovery example: `test_discoverable_async_function` in `scripts/example_of_discoverable_tests/example_of_discoverable_tests.gml`
- Framework self-tests (canonical style, exported on purpose): `scripts/crispy_Self_Test/crispy_Self_Test.gml`
- Fixtures under test: `scripts/scr_food/scr_food.gml`, `scripts/GuiBox/GuiBox.gml`

## Related Documentation
- `README.md` - public API summary and configuration table (mirrored in `notes/crispy_Docs/crispy_Docs.md`)
- `.github/skills/gml-code-conventions/SKILL.md` - house GML style: tabs, Allman braces, `///` doc blocks, two-level struct regions, fluent APIs
- `scripts/crispy_Self_Test/crispy_Self_Test.gml` - mirror these tests before writing new ones

`.github/skills`, `.github/Documentation` and this file are listed in `.gitignore`; edits to them stay local.
