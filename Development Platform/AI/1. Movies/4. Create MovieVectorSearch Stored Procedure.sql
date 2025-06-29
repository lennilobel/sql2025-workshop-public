/* AI: Movies - Create VectorSearch Stored Procedure */

USE MoviesDB
GO

-- Create a stored procedure to run a vector search using the Cosine Distance metric
CREATE OR ALTER PROCEDURE MovieVectorSearch
	@Question varchar(max)
AS
BEGIN

	-- Prepare a vector variable to capture the question vector components
	DECLARE @QuestionVector vector(1536)

	-- Vectorize the question using Azure OpenAI
	EXEC VectorizeText @Question, @QuestionVector OUTPUT

	-- Find the most similar movie based on cosine similarity
	SELECT TOP 1
		Question = @Question,
		Answer = Title,
		CosineDistance = VECTOR_DISTANCE('cosine', @QuestionVector, Vector)
	FROM
		Movie
	ORDER BY
		CosineDistance

END
