/**
 * This test can be discovered by CrispyRunner.Discover()
 */
function test_discoverable_function()
{
	AssertTrue(__is_discovered__, name + ".__is_discovered__ is not true.");
}

function test_discoverable_async_function()
{
	WaitStep(function() {
		AssertTrue(true, "Discovered async function should be able to enqueue checkpoints.");
		return true;
	});

	Timeout(120, "frames");
}