/// @desc Releases the result list owned by the test object.

if (ds_exists(results, ds_type_list) )
{
	ds_list_destroy(results);
}
