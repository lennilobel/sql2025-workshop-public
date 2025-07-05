/* AI: Movies - Vector Search - Create VectorizeText Stored Procedure */

USE MoviesDB
GO

-- Create a stored procedure that can call Azure OpenAI to vectorize any text
CREATE OR ALTER PROCEDURE VectorizeText
	@Text varchar(max),
	@Vector vector(1536) OUTPUT
AS
BEGIN

	-- Construct URL for calling the Azure OpenAI text embeddings model
	DECLARE @OpenAIEndpoint varchar(max) = '[OPENAI-ENDPOINT]'
	DECLARE @OpenAIDeploymentName varchar(max) = '[OPENAI-DEPLOYMENT-NAME]'		-- The 'Text Embedding 3 Small' model yields 1536 components (floating point values) per vector
	DECLARE @OpenAIApiVersion varchar(max) = '2023-05-15'
	DECLARE @Url varchar(max) = CONCAT(@OpenAIEndpoint, 'openai/deployments/', @OpenAIDeploymentName, '/embeddings?api-version=', @OpenAIApiVersion)

	-- Provide the Azure OpenAI API key in the HTTP headers
	DECLARE @OpenAIApiKey varchar(max) = '[OPENAI-API-KEY]'
	DECLARE @Headers varchar(max) = JSON_OBJECT('api-key': @OpenAIApiKey)

	-- Payload includes the text to be vectorized
	DECLARE @Payload varchar(max) = JSON_OBJECT('input': @Text)

	-- Response and return value
	DECLARE @Response nvarchar(max)
	DECLARE @ReturnValue int

	-- Call Azure OpenAI to vectorize the text
	EXEC @ReturnValue = sp_invoke_external_rest_endpoint
		@url = @Url,
		@method = 'POST',
		@headers = @Headers,
		@payload = @Payload,
		@response = @Response OUTPUT

	-- Handle API errors
	IF @ReturnValue != 0
		THROW 50000, @Response, 1

	-- Extract vector from JSON response
	DECLARE @VectorJson varchar(max) = JSON_QUERY(@Response, '$.result.data[0].embedding')

	-- Convert JSON vector to SQL Server's vector type
	SET @Vector = CONVERT(vector(1536), @VectorJson)

END
GO

-- Test the stored procedure
DECLARE @Vector vector(1536)
EXEC VectorizeText 'Sample text to be vectorized', @Vector OUTPUT
SELECT @Vector
