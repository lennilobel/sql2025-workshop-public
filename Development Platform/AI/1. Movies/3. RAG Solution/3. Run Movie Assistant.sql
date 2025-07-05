/* AI: Movies - RAG Solution - Run Movie Assistant */

USE MoviesDB
GO

DECLARE @Title varchar(max)
DECLARE @Synopsis varchar(max)
EXEC MovieAssistant 'Recommend a good sci-fi movie', @Title OUTPUT, @Synopsis OUTPUT
SELECT @Title, @Synopsis
GO

DECLARE @Title varchar(max)
DECLARE @Synopsis varchar(max)
EXEC MovieAssistant 'Al Pacino is one of my favorite actors', @Title OUTPUT, @Synopsis OUTPUT
SELECT @Title, @Synopsis
GO

DECLARE @Title varchar(max)
DECLARE @Synopsis varchar(max)
EXEC MovieAssistant 'I want to laugh out loud to a good comedy', @Title OUTPUT, @Synopsis OUTPUT
SELECT @Title, @Synopsis
GO

DECLARE @Title varchar(max)
DECLARE @Synopsis varchar(max)
EXEC MovieAssistant 'I''m looking for a fantasy flick', @Title OUTPUT, @Synopsis OUTPUT
SELECT @Title, @Synopsis
GO
