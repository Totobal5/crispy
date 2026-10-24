/// @desc Example of a test function that CrispyRunner.Discover() finds by its prefix.
function test_discoverable_function()
{
	AssertTrue(__is_discovered, "Discovered function should be flagged as discovered by the runner.");
}

/// @desc Example of an asynchronous test function that CrispyRunner.Discover() finds by its prefix.
function test_discoverable_async_function()
{
	WaitStep(function()
	{
		AssertTrue(true, "Discovered async function should be able to queue checkpoints.");
		return true;
	});

	Timeout(120, "frames");
}
