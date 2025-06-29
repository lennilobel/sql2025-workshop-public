/* AI: Recipes: RAG Solution - Create RecipeAssistant Stored Procedure */

USE RecipesDB
GO

CREATE OR ALTER PROCEDURE RecipeAssistant @RecipeQuestion nvarchar(max)
AS
BEGIN

	SET NOCOUNT ON

	-- Run a vector search and capture the results as JSON
	DECLARE @RecipeAnswerJsonResults table (JsonResults varchar(max))
	INSERT INTO @RecipeAnswerJsonResults EXEC RecipeVectorSearchJson @RecipeQuestion
	DECLARE @RecipeAnswerJson varchar(max) = (SELECT JsonResults FROM @RecipeAnswerJsonResults)

	-- Call the GPT model to generate the natural language response from the raw JSON results
	DECLARE @RecipeAnswer varchar(max)
	EXEC AskRecipeQuestion @RecipeQuestion, @RecipeAnswerJson, @RecipeAnswer OUTPUT
	PRINT @RecipeAnswer

END
