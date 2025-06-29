/* AI: AdventureWorks: Basic Vector Search - Create VectorizeText Stored Procedure */

USE AdventureWorks2022
GO

-- Create a stored procedure that can call Azure OpenAI to vectorize any text
CREATE PROCEDURE VectorizeText
	@Text varchar(max),
	@Vector vector(1536) OUTPUT
AS
BEGIN

	-- Construct URL for calling the Azure OpenAI text embeddings model
	DECLARE @OpenAIEndpoint varchar(max) = '[OPENAI-ENDPOINT]'
	DECLARE @OpenAIDeploymentName varchar(max) = '[OPENAI-DEPLOYMENT-NAME]'	-- The 'Text Embedding ADA 002' model yields 1536 components (floating point values) per vector
	DECLARE @OpenAIApiVersion varchar(max) = '2023-05-15'
	DECLARE @Url varchar(max) = CONCAT(@OpenAIEndpoint, 'openai/deployments/', @OpenAIDeploymentName, '/embeddings?api-version=', @OpenAIApiVersion)

	-- Payload includes the text to be vectorized
	DECLARE @Payload varchar(max) = JSON_OBJECT('input': @Text)

	-- Response and return value
	DECLARE @Response nvarchar(max)
	DECLARE @ReturnValue int

	-- Call Azure OpenAI to vectorize the text
	EXEC @ReturnValue = sp_invoke_external_rest_endpoint
		@url = @Url,
		@method = 'POST',
        @credential = [https://lenni-openai.openai.azure.com],
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

SELECT
	Vector		= @Vector,
	Dimensions	= VECTORPROPERTY(@Vector, 'Dimensions'),
	BaseType	= VECTORPROPERTY(@Vector, 'BaseType'),
	Magnitude	= VECTOR_NORM(@Vector, 'norm2'),		-- Very close to 1 but not exactly 1, because a rounding error accumulates when you square 1536 values, sum them, and then take the square root
	Normalized	= VECTOR_NORMALIZE(@Vector, 'norm2')	-- Being already normalized, this should return the same vector values
