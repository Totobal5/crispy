/// @desc Host object for CrispyCaseAsync event delegation.

/// @desc Async case that receives this instance's step events.
/// @type {Struct.CrispyCaseAsync|Undefined}
async_case = undefined;

/// @desc Hash used to find the async case Step callback.
/// @type {Real}
hash_on_step = variable_get_hash("OnStep");

/// @desc Hash used to find the async case Begin Step callback.
/// @type {Real}
hash_on_begin_step = variable_get_hash("OnBeginStep");

/// @desc Hash used to find the async case End Step callback.
/// @type {Real}
hash_on_end_step = variable_get_hash("OnEndStep");