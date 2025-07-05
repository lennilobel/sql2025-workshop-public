/* AI: Movies - Create DiskANN Index */

USE MoviesDB
GO

-- Enable the necessary trace flags for DiskANN indexing while the feature is still in preview
DBCC TRACEON(466, 474, 13981, -1)

CREATE VECTOR INDEX MovieVectorDiskANNIndex
  ON Movie (Vector)
  WITH (
    METRIC = 'cosine',
    TYPE = 'diskann',
    MAXDOP = 8
)

SELECT * FROM sys.indexes WHERE name = 'MovieVectorDiskANNIndex'
GO
