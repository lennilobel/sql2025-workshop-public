/* AI: Recipes: VectorSearch - Create RecipeVectorSearch Stored Procedure */

USE RecipesDB
GO

-- Create a stored procedure to run a vector search using the Cosine Distance metric
CREATE OR ALTER PROCEDURE RecipeVectorSearch
    @Question varchar(max)
AS
BEGIN

	-- Prepare a vector variable to capture the question vector components
	DECLARE @QuestionVector vector(1536)

	-- Vectorize the question using Azure OpenAI
	EXEC VectorizeText @Question, @QuestionVector OUTPUT

	-- Find the most similar recipes based on cosine similarity
	SELECT TOP 5
		rv.*,
		CosineDistance = VECTOR_DISTANCE('cosine', @QuestionVector, r.Vector)
	FROM
		Recipe AS r
		INNER JOIN RecipeView AS rv ON rv.RecipeId = r.RecipeId
	ORDER BY
		CosineDistance

END
