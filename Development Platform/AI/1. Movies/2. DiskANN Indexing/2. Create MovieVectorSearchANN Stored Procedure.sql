/* AI: Movies - Create MovieVectorSearchANN Stored Procedure */

USE MoviesDB
GO

-- Create a stored procedure to run a vector search using the VECTOR_DISTANCE function
CREATE OR ALTER PROCEDURE MovieVectorSearchANN
	@Question varchar(max)
AS
BEGIN

	-- Prepare a vector variable to capture the question vector components
	DECLARE @QuestionVector vector(1536)

	-- Vectorize the question using Azure OpenAI
	EXEC VectorizeText @Question, @QuestionVector OUTPUT

	-- Find the most similar movie with VECTOR_SEARCH and DiskANN
	SELECT
		Question = @Question,
		Answer = m.Title,
		Distance = mvs.Distance
	FROM
		VECTOR_SEARCH(
			TABLE       = Movie AS mvt,
			COLUMN      = Vector,
			SIMILAR_TO  = @QuestionVector,
			METRIC      = 'cosine',
			TOP_N       = 1
		) AS mvs
		INNER JOIN Movie AS m ON mvt.MovieId = m.MovieId

END
GO
