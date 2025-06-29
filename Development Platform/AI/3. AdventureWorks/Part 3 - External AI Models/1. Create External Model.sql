/* AI: AdventureWorks: External AI Models - Create External Model */

USE AdventureWorks2022
GO

-- Create roles
CREATE ROLE AIRole		-- Members in this role can access the model
CREATE ROLE NonAIRole	-- Members in this role cannot access the model

-- Create users
CREATE USER AIUser1 WITHOUT LOGIN
CREATE USER AIUser2 WITHOUT LOGIN
CREATE USER NonAIUser1 WITHOUT LOGIN
CREATE USER NonAIUser2 WITHOUT LOGIN

-- Add users to roles
ALTER ROLE AIRole ADD MEMBER AIUser1
ALTER ROLE AIRole ADD MEMBER AIUser2
ALTER ROLE NonAIRole ADD MEMBER NonAIUser1
ALTER ROLE NonAIRole ADD MEMBER NonAIUser2

-- Grant AIRole users permission to use the database scoped credential that the model uses
GRANT REFERENCES ON DATABASE SCOPED CREDENTIAL::[https://lenni-openai.openai.azure.com] TO AIRole

-- Create the model that can only be accessed by AIRole members
CREATE EXTERNAL MODEL ProductTextEmbeddingModel
AUTHORIZATION AIRole
WITH (
      LOCATION = 'https://lenni-openai.openai.azure.com/openai/deployments/lenni-text-embedding-ada-002/embeddings?api-version=2023-03-15-preview',
      API_FORMAT = 'Azure OpenAI',
      MODEL_TYPE = EMBEDDINGS,
      MODEL = 'lenni-text-embedding-ada-002',
      CREDENTIAL = [https://lenni-openai.openai.azure.com],
)
GO

-- Test the external model as database user dbo (has full permissions)
SELECT USER_NAME()

DECLARE @Vector vector(1536)
SELECT @Vector = AI_GENERATE_EMBEDDINGS('Sample text to be vectorized' USE MODEL ProductTextEmbeddingModel)

SELECT
	Vector		= @Vector,
	Dimensions	= VECTORPROPERTY(@Vector, 'Dimensions'),
	BaseType	= VECTORPROPERTY(@Vector, 'BaseType'),
	Magnitude	= VECTOR_NORM(@Vector, 'norm2'),		-- Very close to 1 but not exactly 1, because a rounding error accumulates when you square 1536 values, sum them, and then take the square root
	Normalized	= VECTOR_NORMALIZE(@Vector, 'norm2')	-- Being already normalized, this should return the same vector values

GO

-- Test as NonAIUser1 (should fail)
EXECUTE AS USER = 'NonAIUser1'

DECLARE @Vector vector(1536)
SELECT @Vector = AI_GENERATE_EMBEDDINGS('Sample text to be vectorized' USE MODEL ProductTextEmbeddingModel)

REVERT
GO

-- Test as NonAIUser2 (should fail)
EXECUTE AS USER = 'NonAIUser2'

DECLARE @Vector vector(1536)
SELECT @Vector = AI_GENERATE_EMBEDDINGS('Sample text to be vectorized' USE MODEL ProductTextEmbeddingModel)

REVERT
GO

-- Test as AIUser1 (should succeed)
EXECUTE AS USER = 'AIUser1'

DECLARE @Vector vector(1536)
SELECT @Vector = AI_GENERATE_EMBEDDINGS('Sample text to be vectorized' USE MODEL ProductTextEmbeddingModel)

REVERT
GO

-- Test as AIUser2 (should succeed)
EXECUTE AS USER = 'AIUser2'

DECLARE @Vector vector(1536)
SELECT @Vector = AI_GENERATE_EMBEDDINGS('Sample text to be vectorized' USE MODEL ProductTextEmbeddingModel)

REVERT
GO
