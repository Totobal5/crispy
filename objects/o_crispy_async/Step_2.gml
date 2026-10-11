/// @desc Relay End Step to the attached async case.
if (is_struct(async_case) && struct_exists_from_hash(async_case, hash_on_end_step) )
{
	var _on_end_step = struct_get_from_hash(async_case, hash_on_end_step);
	if (is_callable(_on_end_step) )
	{
		var _bound = method(async_case, _on_end_step);
		_bound();
	}
	else
	{
		instance_destroy();
	}
}
else
{
	instance_destroy();
}
