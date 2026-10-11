/// @desc Relay Begin Step to the attached async case.
if (is_struct(async_case) && struct_exists_from_hash(async_case, hash_on_begin_step) )
{
	var _on_begin_step = struct_get_from_hash(async_case, hash_on_begin_step);
	if (is_callable(_on_begin_step) )
	{
		var _bound = method(async_case, _on_begin_step);
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