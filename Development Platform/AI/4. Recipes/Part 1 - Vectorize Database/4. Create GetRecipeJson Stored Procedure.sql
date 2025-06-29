/* AI: Recipes: Vectorize Database - Create GetRecipeJson Stored Procedure */

USE RecipesDB
GO

CREATE OR ALTER PROCEDURE GetRecipeJson
    @RecipeId int,
    @RecipeJson nvarchar(max) OUTPUT
AS
BEGIN

    SET @RecipeJson = (
        SELECT *
        FROM RecipeView
        WHERE RecipeId = @RecipeId
        FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
    )

END
GO

DECLARE @RecipeJson nvarchar(max)
EXEC GetRecipeJson @RecipeId = 1, @RecipeJson = @RecipeJson OUTPUT
SELECT @RecipeJson
