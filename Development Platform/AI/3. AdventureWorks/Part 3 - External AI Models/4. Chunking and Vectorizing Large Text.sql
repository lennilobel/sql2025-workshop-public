/* AI: AdventureWorks: External AI Models - Chunking and Vectorizing Large Text */

USE AdventureWorks2022
GO

-- Chunk the product text with AI_GENERATE_CHUNKS
;WITH ProductTextCte AS (
	SELECT
		ProductText = 'Name: ' || p.Name || ', Description: ' || pd.Description,
		p.ProductID,
		pd.ProductDescriptionID
	FROM
		Production.ProductVector					AS pv
		INNER JOIN Production.Product				AS p	ON p.ProductId = pv.ProductId
		INNER JOIN Production.ProductDescription	AS pd	ON pd.ProductDescriptionID = pv.ProductDescriptionID
)
SELECT
	TextLength = LEN(p.ProductText),
	p.*,
	c.*
FROM
	ProductTextCte AS p
	CROSS APPLY AI_GENERATE_CHUNKS(
		SOURCE = p.ProductText,
		CHUNK_TYPE = 'FIXED',
		CHUNK_SIZE = 100,
		OVERLAP = 10
	) AS c
ORDER BY
	p.ProductText

-- Chunk and vectorize the product text with AI_GENERATE_CHUNKS AND AI_GENERATE_EMBEDDINGS
;WITH ProductTextCte AS (
	SELECT
		ProductText = 'Name: ' || p.Name || ', Description: ' || pd.Description,
		p.ProductID,
		pd.ProductDescriptionID
	FROM
		Production.ProductVector					AS pv
		INNER JOIN Production.Product				AS p	ON p.ProductId = pv.ProductId
		INNER JOIN Production.ProductDescription	AS pd	ON pd.ProductDescriptionID = pv.ProductDescriptionID
)
SELECT
	p.ProductId,
	p.ProductDescriptionID,
	TextLength = LEN(p.ProductText),
	ProductTextChunk = c.chunk,
	ProductTextChunkVector = AI_GENERATE_EMBEDDINGS(c.Chunk USE MODEL ProductTextEmbeddingModel)
FROM
	ProductTextCte AS p
	CROSS APPLY AI_GENERATE_CHUNKS(
		SOURCE = p.ProductText,
		CHUNK_TYPE = 'FIXED',
		CHUNK_SIZE = 100,
		OVERLAP = 10
	) AS c
ORDER BY
	p.ProductText
