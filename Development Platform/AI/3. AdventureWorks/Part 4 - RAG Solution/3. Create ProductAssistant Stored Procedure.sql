/* AI: AdventureWorks: RAG Solition - Create ProductAssistant Stored Procedure */

USE AdventureWorks2022
GO

CREATE OR ALTER PROCEDURE ProductAssistant @ProductQuestion nvarchar(max)
AS
BEGIN

	SET NOCOUNT ON

	-- Run a vector search and capture the results as JSON
	DECLARE @ProductAnswerJsonResults table (JsonResults varchar(max))
	INSERT INTO @ProductAnswerJsonResults EXEC ProductVectorSearchJson @ProductQuestion
	DECLARE @ProductAnswerJson varchar(max) = (SELECT JsonResults FROM @ProductAnswerJsonResults)

	-- Call the GPT model to generate the natural language response from the raw JSON results
	DECLARE @ProductAnswer varchar(max)
	EXEC AskProductQuestion @ProductQuestion, @ProductAnswerJson, @ProductAnswer OUTPUT
	PRINT @ProductAnswer

END
