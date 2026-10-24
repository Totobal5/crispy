/// @desc Sample food item used by the discoverable test examples.
/// @param {String} name Name of the food.
/// @param {Array<Struct.Ingredient>} ingredients Ingredients that make up the food.
function Food(_name, _ingredients) constructor
{
	if (!is_string(_name) )
	{
		throw($"{instanceof(self)} \"_name\" expected a string, received {typeof(_name)}.");
	}

	if (!is_array(_ingredients) )
	{
		throw($"{instanceof(self)} \"_ingredients\" expected an array, received {typeof(_ingredients)}.");
	}

	var i = 0;
	repeat (array_length(_ingredients) )
	{
		var _item = _ingredients[i];

		if (!is_instanceof(_item, Ingredient) )
		{
			throw($"{instanceof(self)} \"_ingredients\" expected an instance of Ingredient, received {__crispy_type(_item)}.");
		}

		++i;
	}

	#region PRIVATE

		#region FIELDS

		/// @ignore
		/// @type {String}
		/// @desc Name of the food.
		__name = _name;

		/// @ignore
		/// @type {Array<Struct.Ingredient>}
		/// @desc Ingredients that make up the food.
		__ingredients = _ingredients;

		#endregion

	#endregion

	#region PUBLIC

		#region METHODS

		/// @desc Checks whether the food contains the named ingredient.
		/// @param {String} name Name of the ingredient.
		/// @return {Bool} Whether the food contains the ingredient.
		static HasIngredient = function(_name)
		{
			if (!is_string(_name) )
			{
				__crispy_error($"Food.HasIngredient() 'name' expected a string, received {typeof(_name)}.");
				return false;
			}

			var i = 0;
			repeat (array_length(__ingredients) )
			{
				if (__ingredients[i].GetName() == _name) return true;

				++i;
			}

			return false;
		}

		#endregion

		#region STATE QUERIES

		/// @desc Checks whether every ingredient is gluten free.
		/// @return {Bool} Whether the food is gluten free.
		static IsGlutenFree = function()
		{
			var i = 0;
			repeat (array_length(__ingredients) )
			{
				if (!__ingredients[i].IsGlutenFree() ) return false;

				++i;
			}

			return true;
		}

		#endregion

		#region GETTERS

		/// @desc Gets the name of the food.
		/// @return {String} Name of the food.
		static GetName = function()
		{
			return __name;
		}

		/// @desc Gets the ingredients of the food.
		/// @return {Array<Struct.Ingredient>} Ingredients that make up the food.
		static GetIngredients = function()
		{
			return __ingredients;
		}

		/// @desc Gets the number of ingredients of the food.
		/// @return {Real} Number of ingredients.
		static GetIngredientNumber = function()
		{
			return array_length(__ingredients);
		}

		#endregion

	#endregion
}

/// @desc Sample ingredient used by the discoverable test examples.
/// @param {String} name Name of the ingredient.
/// @param {Bool} [is_gluten_free=false] Whether the ingredient is gluten free.
function Ingredient(_name, _is_gluten_free = false) constructor
{
	if (!is_string(_name) )
	{
		throw($"{instanceof(self)} \"_name\" expected a string, received {typeof(_name)}.");
	}

	if (!is_real(_is_gluten_free) && !is_bool(_is_gluten_free) )
	{
		throw($"{instanceof(self)} \"_is_gluten_free\" expected a boolean, received {typeof(_is_gluten_free)}.");
	}

	#region PRIVATE

		#region FIELDS

		/// @ignore
		/// @type {String}
		/// @desc Name of the ingredient.
		__name = _name;

		/// @ignore
		/// @type {Bool}
		/// @desc Whether the ingredient is gluten free.
		__is_gluten_free = _is_gluten_free;

		#endregion

	#endregion

	#region PUBLIC

		#region STATE QUERIES

		/// @desc Checks whether the ingredient is gluten free.
		/// @return {Bool} Whether the ingredient is gluten free.
		static IsGlutenFree = function()
		{
			return __is_gluten_free;
		}

		#endregion

		#region GETTERS

		/// @desc Gets the name of the ingredient.
		/// @return {String} Name of the ingredient.
		static GetName = function()
		{
			return __name;
		}

		#endregion

	#endregion
}
