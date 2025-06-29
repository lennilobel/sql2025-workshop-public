/* AI: AdventureWorks: DiskANN Indexing - Create a DiskANN vector index */

USE AdventureWorks2022
GO

CREATE VECTOR INDEX ProductVectorDiskANNIndex 
	ON Production.ProductVector (ProductVector)
	WITH (
		METRIC = 'cosine',
		TYPE = 'diskann',
		MAXDOP = 8
	)
GO

SELECT * FROM sys.indexes WHERE name = 'ProductVectorDiskANNIndex'
GO

-- Table is now read-only
UPDATE Production.ProductVector SET ProductVector = NULL
