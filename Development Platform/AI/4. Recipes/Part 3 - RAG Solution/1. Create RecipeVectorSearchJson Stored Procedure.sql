/* AI: Recipes: RAG Solution - Create RecipeVectorSearchJson Stored Procedure */

USE RecipesDB
GO

-- Create a stored procedure to run a vector search using the Cosine Distance metric, returning the results as JSON
CREATE OR ALTER PROCEDURE RecipeVectorSearchJson
	@Question varchar(max)
AS
BEGIN

	-- Prepare a vector variable to capture the question vector components
	DECLARE @QuestionVector vector(1536)

	-- Vectorize the question using Azure OpenAI
	EXEC VectorizeText @Question, @QuestionVector OUTPUT

	-- Find the most similar recipes based on cosine similarity
	DECLARE @JsonResults varchar(max) = (
		SELECT TOP 5
			rv.*,
			CosineDistance = VECTOR_DISTANCE('cosine', @QuestionVector, r.Vector)
		FROM
			Recipe AS r
			INNER JOIN RecipeView AS rv ON rv.RecipeId = r.RecipeId
		WHERE
			VECTOR_DISTANCE('cosine', @QuestionVector, r.Vector) < .65
		ORDER BY CosineDistance
		FOR JSON AUTO
	)

	SELECT JsonResults = @JsonResults

END
GO

EXEC RecipeVectorSearch 'I love chicken, kebab, and falafel'
EXEC RecipeVectorSearchJson 'I love chicken, kebab, and falafel'
