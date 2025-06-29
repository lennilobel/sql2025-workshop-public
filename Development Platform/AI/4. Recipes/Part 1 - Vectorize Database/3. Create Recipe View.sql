/* AI: Recipes: Vectorize Database - Create Recipe View */

USE RecipesDB
GO

CREATE OR ALTER VIEW RecipeView AS
    SELECT 
        r.RecipeId,
        r.RecipeName,
        r.PrepTimeMinutes,
        r.CookTimeMinutes,
        r.Servings,
        r.Difficulty,
        r.Cuisine,
        r.CaloriesPerService,
        r.Rating,
        r.ReviewCount,
        Ingredients = (
            SELECT STRING_AGG(CONCAT(i.RowNum, ') ', i.IngredientName), '. ')
            FROM (
                SELECT 
                    IngredientName,
                    ROW_NUMBER() OVER (ORDER BY IngredientId) AS RowNum
                FROM Ingredient
                WHERE RecipeId = r.RecipeId
            ) AS i
        ),
        Instructions = (
            SELECT STRING_AGG(CONCAT(i.RowNum, ') ', i.InstructionText), ' ')
            FROM (
                SELECT 
                    InstructionText,
                    ROW_NUMBER() OVER (ORDER BY InstructionId) AS RowNum
                FROM Instruction
                WHERE RecipeId = r.RecipeId
            ) AS i
        ),
        MealType = (
            SELECT STRING_AGG(mt.MealTypeName, '; ')
            FROM MealType AS mt
            WHERE mt.RecipeId = r.RecipeId
        ),
        Tags = (
            SELECT STRING_AGG(t.TagName, '; ')
            FROM Tag AS t
            WHERE t.RecipeId = r.RecipeId
        )
    FROM Recipe AS r
GO

SELECT TOP 5 * FROM RecipeView
