/* AI: Movies - Create GetMovieSynopsis Stored Procedure */

USE MoviesDB
GO

-- Create a stored procedure that can call Azure OpenAI to chat using a completion model
CREATE OR ALTER PROCEDURE GetMovieSynopsis
	@MovieTitle varchar(max),
	@MovieSynopsis varchar(max) OUTPUT
AS
BEGIN

	-- Construct URL for calling the Azure OpenAI chat completions model
	DECLARE @OpenAIEndpoint varchar(max) = '[OPENAI-ENDPOINT]'
	DECLARE @OpenAIDeploymentName varchar(max) = '[OPENAI-DEPLOYMENT-NAME]'  -- The 'GPT 4o' chat completion model
	DECLARE @OpenAIApiVersion varchar(max) = '2023-05-15'
	DECLARE @Url varchar(max) = CONCAT(@OpenAIEndpoint, 'openai/deployments/', @OpenAIDeploymentName, '/chat/completions?api-version=2023-05-15')

	-- Provide the Azure OpenAI API key in the HTTP headers
	DECLARE @OpenAIApiKey varchar(max) = '[OPENAI-API-KEY]'
	DECLARE @Headers varchar(max) = JSON_OBJECT('api-key': @OpenAIApiKey)

	-- Prepare a system prompt and user prompt
	DECLARE @SystemPrompt varchar(max) =
		'You are an assistant that provides a synopsis of the movie title retrieved by a natural language vector search. ' ||
		'The synopsis should be limited to one sentence, followed by three recommended titles (without synopses) for similar movies.'
	DECLARE @UserPrompt varchar(max) = 'The movie title is: "' || @MovieTitle || '"'

	-- Payload includes a message array containing the system prompt and user prompt
	DECLARE @Payload varchar(max) = JSON_OBJECT(
		'messages': JSON_ARRAY(
			JSON_OBJECT('role': 'system', 'content': @SystemPrompt),
			JSON_OBJECT('role': 'user', 'content': @UserPrompt)
		),
		'max_tokens': 1000,        -- Max number of tokens for the response; the more tokens you specify (spend), the more verbose the response
		'temperature': 1.0,        -- Range is 0.0 to 2.0; controls "apparent creativity"; higher = more random, lower = more deterministic
		'frequency_penalty': 0.0,  -- Range is -2.0 to 2.0; controls likelihood of repeating words; higher = less likely, lower = more likely
		'presence_penalty': 0.0,   -- Range is -2.0 to 2.0; controls likelihood of introducing new topics; higher = more likely, lower = less likely
		'top_p': 0.95              -- Range is 0.0 to 2.0; aka "Top P sampling"; temperature alternative; controls diversity of responses (1.0 is full random, lower values limit randomness)
	)

    -- Response and return value
	DECLARE @Response nvarchar(max)
	DECLARE @ReturnValue int

    -- Call Azure OpenAI to get chat completion
	EXEC @ReturnValue = sp_invoke_external_rest_endpoint
		@url = @Url,
		@method = 'POST',
		@headers = @Headers,
		@payload = @Payload,
		@response = @Response OUTPUT

	-- Handle API errors
	IF @ReturnValue != 0
		THROW 50000, @Response, 1

	-- Extract chat completion answer from JSON response
	SET @MovieSynopsis = JSON_VALUE(@Response, '$.result.choices[0].message.content')

END
