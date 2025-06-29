/* AI: Movies - Ask Movie Questions */

USE MoviesDB
GO

DECLARE @Title varchar(max) = (SELECT Title FROM Movie WHERE MovieId = 1)
DECLARE @Synopsis varchar(max)
EXEC AskMovieQuestion @Title, @Synopsis OUTPUT
SELECT @Synopsis
GO

DECLARE @Title varchar(max) = (SELECT Title FROM Movie WHERE MovieId = 2)
DECLARE @Synopsis varchar(max)
EXEC AskMovieQuestion @Title, @Synopsis OUTPUT
SELECT @Synopsis
GO

DECLARE @Title varchar(max) = (SELECT Title FROM Movie WHERE MovieId = 3)
DECLARE @Synopsis varchar(max)
EXEC AskMovieQuestion @Title, @Synopsis OUTPUT
SELECT @Synopsis
GO

DECLARE @Title varchar(max) = (SELECT Title FROM Movie WHERE MovieId = 4)
DECLARE @Synopsis varchar(max)
EXEC AskMovieQuestion @Title, @Synopsis OUTPUT
SELECT @Synopsis
GO
