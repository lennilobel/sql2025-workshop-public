/* AI: Recipes: RAG Solution - Create AskRecipeQuestion Stored Procedure */

USE RecipesDB
GO

-- Create a stored procedure that can call Azure OpenAI to chat using a completion model
CREATE OR ALTER PROCEDURE AskRecipeQuestion
    @RecipeQuestion varchar(max),
	@RecipeAnswerJson varchar(max),
    @RecipeAnswer varchar(max) OUTPUT
AS
BEGIN

	DECLARE @SystemPrompt varchar(max) = '
		You are an assistant that helps people find recipes from a database.
		
		A vector search returns recipe results similar to a natural language query posed by the user. Your job is
		to take the raw JSON results of the vector search and generate a natural language response that starts with
		a sentence or two related to the user''s question, followed by each recipe''s details.

		Number each recipe sequentially. Include prep time, cook time, servings, ingredients, and
		instructions. Do not include difficulty, cuisine, calories, tags, rating, review count, and meal type.
		Format the ingredients as a comma-separated string, and format the instructions as a numbered list.
		Do not include markdown syntax, such as double asterisks or pound signs.

		Include all the recipes returned by the vector search, even those that don''t relate to the user''s
		question. However, call out those recipes that don''t relate to the user''s question. If there are no
		recipe results, apologize and explain that there are no recipes to suggest.
		
		If the user asks a question unrelated to recipes, try to answer it anyway.
	'

	DECLARE @UserPrompt varchar(max) = CONCAT('
		The user asked "', @RecipeQuestion, '", and the vector search returned the following recipes: ', @RecipeAnswerJson, '
	')

    -- Construct URL for calling the Azure OpenAI chat completions model
    DECLARE @OpenAIEndpoint varchar(max) = '[OPENAI-ENDPOINT]'
    DECLARE @OpenAIDeploymentName varchar(max) = '[OPENAI-DEPLOYMENT-NAME]'   -- The 'GPT 4o' chat completion model
    DECLARE @OpenAIApiVersion varchar(max) = '2023-05-15'
    DECLARE @Url varchar(max) = CONCAT(@OpenAIEndpoint, 'openai/deployments/', @OpenAIDeploymentName, '/chat/completions?api-version=', @OpenAIApiVersion)

	-- Provide the Azure OpenAI API key in the HTTP headers
	DECLARE @OpenAIApiKey varchar(max) = '[OPENAI-API-KEY]'			-- Your Azure OpenAI API key
    DECLARE @Headers varchar(max) = JSON_OBJECT('api-key': @OpenAIApiKey)

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

	-- Call Azure OpenAI to get a chat completion response
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
	SET @RecipeAnswer = JSON_VALUE(@Response, '$.result.choices[0].message.content')

END
GO

DECLARE @RecipeAnswer varchar(max)
EXEC AskRecipeQuestion 'What is the capital of France?', 'No database results', @RecipeAnswer OUTPUT
PRINT @RecipeAnswer 
