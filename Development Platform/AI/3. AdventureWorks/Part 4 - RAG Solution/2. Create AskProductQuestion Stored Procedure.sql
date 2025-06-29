/* AI: AdventureWorks: RAG Solition - Create AskProductQuestion Stored Procedure */

USE AdventureWorks2022
GO

-- Create a stored procedure that can call Azure OpenAI to chat using a completion model
CREATE OR ALTER PROCEDURE AskProductQuestion
    @ProductQuestion varchar(max),
    @JsonResults varchar(max),
    @ProductAnswer varchar(max) OUTPUT
AS
BEGIN

    DECLARE @SystemPrompt varchar(max) = '
        You are an assistant that helps people find bicycle and related products from vectorized
        product descriptions in the AdventureWorks2022 database. Your demeanor is upbeat and
        friendly.
    
        A vector search returns product results similar to a natural language query posed by the user.
        Your job is to take the raw results of the vector search and generate a natural language
        response that starts with a sentence or two related to the user''s question, followed by
        the details of each product in the search results.

        Do not include markdown syntax, such as double asterisks or pound signs. Do not include emojis either.

        Include all the products returned by the vector search, even those that don''t relate to the user''s
        question. However, call out those products that don''t relate to the user''s question. If there are no
        product results, apologize and explain that there are no products to suggest.
    
        If the user asks a question unrelated to products, try to answer it anyway, but stress that your primary
        purpose is to help with bicycles and related products in the database.
    '

    DECLARE @UserPrompt varchar(max) = CONCAT('
        The user asked "', @ProductQuestion, '", and the vector search returned the following products: ', @JsonResults, '
    ')

    -- Construct URL for calling the Azure OpenAI chat completions model
    DECLARE @OpenAIEndpoint varchar(max) = '[OPENAI-ENDPOINT]'
    DECLARE @OpenAIDeploymentName varchar(max) = '[OPENAI-DEPLOYMENT-NAME]'   -- The 'GPT 4o' chat completion model
    DECLARE @OpenAIApiVersion varchar(max) = '2023-05-15'
    DECLARE @Url varchar(max) = CONCAT(@OpenAIEndpoint, 'openai/deployments/', @OpenAIDeploymentName, '/chat/completions?api-version=', @OpenAIApiVersion)

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
        @credential = [https://lenni-openai.openai.azure.com],
        @payload = @Payload,
        @response = @Response OUTPUT

  -- Handle API errors
  IF @ReturnValue != 0
    THROW 50000, @Response, 1

  -- Extract chat completion answer from JSON response
  SET @ProductAnswer = JSON_VALUE(@Response, '$.result.choices[0].message.content')

END
GO

DECLARE @ProductAnswer varchar(max)

EXEC AskProductQuestion
    @ProductQuestion    = 'What is the capital of France?',
    @JsonResults        = '[]',
    @ProductAnswer      = @ProductAnswer OUTPUT

PRINT @ProductAnswer 
