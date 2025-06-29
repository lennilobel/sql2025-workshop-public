/* AI: Movies - Create Movies Database */

USE master
GO

CREATE DATABASE MoviesDB
GO

USE MoviesDB
GO

-- Allow SQL Server to call external REST endpoints
sp_configure 'external rest endpoint enabled', 1
RECONFIGURE
GO

-- Create a table to hold movie titles and associated vectors
CREATE TABLE Movie (
	MovieId int IDENTITY,
	Title varchar(50),
	Vector vector(1536)
)

-- Populate four movie titles
INSERT INTO Movie (Title) VALUES
	('Return of the Jedi'),
	('The Godfather'),
	('Animal House'),
	('The Two Towers')

-- View the movie titles with no vectors
SELECT * FROM Movie
