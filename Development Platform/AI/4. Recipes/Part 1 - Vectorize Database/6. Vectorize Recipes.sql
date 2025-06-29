/* AI: Recipes: Vectorize Database - Vectorize Recipes */

USE RecipesDB
GO

ALTER TABLE Recipe ADD Vector vector(1536)
GO

DECLARE @RecipeId int
DECLARE @RecipeJson varchar(max)
DECLARE @Vector vector(1536)

DECLARE curRecipes CURSOR FOR
	SELECT RecipeId FROM Recipe

OPEN curRecipes
FETCH NEXT FROM curRecipes INTO @RecipeId

WHILE @@FETCH_STATUS = 0
BEGIN

	-- Get the JSON content for the recipe
	EXEC GetRecipeJson @RecipeId, @RecipeJson OUTPUT

	-- Generate vector for the recipe
	EXEC VectorizeText @RecipeJson, @Vector OUTPUT

	-- Store vector in the Recipe table
	UPDATE Recipe
	SET Vector = @Vector
	WHERE RecipeId = @RecipeId

	FETCH NEXT FROM curRecipes INTO @RecipeId

END

CLOSE curRecipes
DEALLOCATE curRecipes
GO

SELECT * FROM Recipe
