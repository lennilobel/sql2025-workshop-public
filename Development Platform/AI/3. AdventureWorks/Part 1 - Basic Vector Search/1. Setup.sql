/* AI: AdventureWorks: Basic Vector Search - Setup */

-- Enable REST API support for the system procedure sp_invoke_external_rest_endpoint
USE master
GO

EXEC sp_configure 'external rest endpoint enabled', 1
GO
RECONFIGURE WITH OVERRIDE
GO

-- Enable vector index and search for CTP builds
DBCC TRACEON (466, 13981, -1) 
GO

-- Enable SQL Server 2025 AI functionality in the database
ALTER DATABASE AdventureWorks2022 SET COMPATIBILITY_LEVEL = 170

USE AdventureWorks2022
GO

-- Create a master key to encrypt the database scoped credential
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '[PASSWORD]'

-- Create a database scoped credential for the OpenAI API
CREATE DATABASE SCOPED CREDENTIAL [https://lenni-openai.openai.azure.com] WITH
	IDENTITY = 'HTTPEndpointHeaders',
	SECRET = '[SECRET]'
