/* AI: AdventureWorks - Cleanup */

USE AdventureWorks2022
GO

DROP PROCEDURE		IF EXISTS SearchProductsANN
DROP PROCEDURE		IF EXISTS SearchProductsKNN
DROP INDEX			IF EXISTS ProductVectorDiskANNIndex ON Production.ProductVector
DROP TABLE			IF EXISTS Production.ProductVector
DROP PROCEDURE		IF EXISTS VectorizeText
DROP USER			IF EXISTS AIUser1
DROP USER			IF EXISTS AIUser2
DROP USER			IF EXISTS NonAIUser1
DROP USER			IF EXISTS NonAIUser2
DROP ROLE			IF EXISTS AIRole
DROP ROLE			IF EXISTS NonAIRole

IF EXISTS (SELECT * FROM sys.external_models WHERE name = 'ProductTextEmbeddingModel')
	DROP EXTERNAL MODEL ProductTextEmbeddingModel

IF EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = 'https://lenni-openai.openai.azure.com')
	DROP DATABASE SCOPED CREDENTIAL [https://lenni-openai.openai.azure.com]

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    DROP MASTER KEY
