/* AI: Movies - Vector Search - Run Movie Vector Searches */

USE MoviesDB
GO

-- Movie phrases
EXEC MovieVectorSearch 'May the force be with you'
EXEC MovieVectorSearch 'I''m gonna make him an offer he can''t refuse'
EXEC MovieVectorSearch 'Drunk and stupid is no way to go through life, son'
EXEC MovieVectorSearch 'One ring to rule them all'

-- Movie characters
EXEC MovieVectorSearch 'Luke Skywalker'
EXEC MovieVectorSearch 'Don Corleone'
EXEC MovieVectorSearch 'James Blutarsky'
EXEC MovieVectorSearch 'Gandalf'

-- Movie actors
EXEC MovieVectorSearch 'Mark Hamill'
EXEC MovieVectorSearch 'Al Pacino'
EXEC MovieVectorSearch 'John Belushi'
EXEC MovieVectorSearch 'Elijah Wood'

-- Movie location references
EXEC MovieVectorSearch 'Tatooine'
EXEC MovieVectorSearch 'Sicily'
EXEC MovieVectorSearch 'Faber College'
EXEC MovieVectorSearch 'Mordor'

-- Movie genres
EXEC MovieVectorSearch 'Science fiction'
EXEC MovieVectorSearch 'Crime'
EXEC MovieVectorSearch 'Comedy'
EXEC MovieVectorSearch 'Fantasy/Adventure'
