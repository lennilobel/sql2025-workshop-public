/* AI: Movies - DiskANN Indexing - Run Movie Vector ANN Searches */

USE MoviesDB
GO

/* AI: Movies - Run Movie Vector ANN Searches */

USE MoviesDB
GO

-- Movie phrases
EXEC MovieVectorSearchANN 'May the force be with you'
EXEC MovieVectorSearchANN 'I''m gonna make him an offer he can''t refuse'
EXEC MovieVectorSearchANN 'Drunk and stupid is no way to go through life, son'
EXEC MovieVectorSearchANN 'One ring to rule them all'

-- Movie characters
EXEC MovieVectorSearchANN 'Luke Skywalker'
EXEC MovieVectorSearchANN 'Don Corleone'
EXEC MovieVectorSearchANN 'James Blutarsky'
EXEC MovieVectorSearchANN 'Gandalf'

-- Movie actors
EXEC MovieVectorSearchANN 'Mark Hamill'
EXEC MovieVectorSearchANN 'Al Pacino'
EXEC MovieVectorSearchANN 'John Belushi'
EXEC MovieVectorSearchANN 'Elijah Wood'

-- Movie location references
EXEC MovieVectorSearchANN 'Tatooine'
EXEC MovieVectorSearchANN 'Sicily'
EXEC MovieVectorSearchANN 'Faber College'
EXEC MovieVectorSearchANN 'Mordor'

-- Movie genres
EXEC MovieVectorSearchANN 'Science fiction'
EXEC MovieVectorSearchANN 'Crime'
EXEC MovieVectorSearchANN 'Comedy'
EXEC MovieVectorSearchANN 'Fantasy/Adventure'
