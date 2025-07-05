/* AI: Movies - Create MovieAssistant Stored Procedure */

USE MoviesDB
GO

-- Create a stored procedure that can call Azure OpenAI to chat using a completion model
CREATE OR ALTER PROCEDURE MovieAssistant
	@Question varchar(max),
	@MovieTitle varchar(max) OUTPUT,
	@MovieSynopsis varchar(max) OUTPUT
AS
BEGIN

	-- RAG Step 1. Run a DiskANN-indexed vector search on a natural language question to get the matching movie title

	DECLARE @Result table (
		Question varchar(max),
		Answer varchar(max),
		Distance float
	)

	INSERT INTO @Result
	 EXEC MovieVectorSearchANN @Question

	SELECT @MovieTitle = Answer FROM @Result

	-- RAG Step 2. Send the movie title result to OpenAI for a natural language response of the movie synopsis with recommendations

	EXEC GetMovieSynopsis @MovieTitle, @MovieSynopsis OUTPUT

END
