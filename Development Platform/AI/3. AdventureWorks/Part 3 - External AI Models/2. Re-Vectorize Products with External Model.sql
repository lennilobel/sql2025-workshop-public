/* AI: AdventureWorks: External AI Models - Re-Vectorize Products with External Model */

USE AdventureWorks2022
GO

-- Clear previous vectors fails, because the table is read-only due to the vector index
UPDATE Production.ProductVector SET ProductVector = NULL

-- Delete existing DiskANN index to re-enable writes to the table
DROP INDEX ProductVectorDiskANNIndex ON Production.ProductVector

-- Clear previous vectors
UPDATE Production.ProductVector SET ProductVector = NULL
SELECT * FROM Production.ProductVector

-- Re-vectorize using the external model
SET NOCOUNT ON

DECLARE @ProductName			nvarchar(max)
DECLARE @ProductDescription		nvarchar(max)
DECLARE @ProductID				int
DECLARE @ProductDescriptionID	int

DECLARE ProductCursor CURSOR FOR
	SELECT
		p.Name,
		pd.Description,
		p.ProductID,
		pd.ProductDescriptionID
	FROM
		Production.ProductVector					AS pv
		INNER JOIN Production.Product				AS p	ON p.ProductId = pv.ProductId
		INNER JOIN Production.ProductDescription	AS pd	ON pd.ProductDescriptionID = pv.ProductDescriptionID
	ORDER BY
		p.Name

OPEN ProductCursor

	FETCH NEXT FROM ProductCursor INTO @ProductName, @ProductDescription, @ProductID, @ProductDescriptionID

	DECLARE @Counter int = 1

	WHILE @@FETCH_STATUS = 0
	BEGIN

		DECLARE @ProductText nvarchar(max) = (SELECT 'Name: ' || @ProductName || ', Description: ' || @ProductDescription)

		DECLARE @Message nvarchar(max) = @Counter || ' - ' || @ProductText
		RAISERROR(@Message, 0, 1) WITH NOWAIT

		DECLARE @ProductVector vector(1536)
		SELECT @ProductVector = AI_GENERATE_EMBEDDINGS(@ProductText USE MODEL ProductTextEmbeddingModel)	--	<- replaces EXEC VectorizeText

		UPDATE Production.ProductVector
		SET ProductVector = @ProductVector
		WHERE ProductID = @ProductID

		FETCH NEXT FROM ProductCursor INTO @ProductName, @ProductDescription, @ProductID, @ProductDescriptionID
		
		SET @Counter += 1

	END

CLOSE ProductCursor
DEALLOCATE ProductCursor
SET NOCOUNT OFF
GO

-- Examine the generated product vectors
SELECT
	p.Name,
	pd.Description,
	pv.ProductID,
	pv.ProductDescriptionID,
	pv.ProductVector,
	Dimensions	= VECTORPROPERTY(ProductVector, 'Dimensions'),
	BaseType	= VECTORPROPERTY(ProductVector, 'BaseType'),
	Magnitude	= VECTOR_NORM(ProductVector, 'norm2'),		-- Very close to 1 but not exactly 1, because a rounding error accumulates when you square 1536 values, sum them, and then take the square root
	Normalized	= VECTOR_NORMALIZE(ProductVector, 'norm2')	-- Being already normalized, this should return the same vector values
FROM
	Production.ProductVector					AS pv
	INNER JOIN Production.Product				AS p	ON p.ProductID = pv.ProductID			
	INNER JOIN Production.ProductDescription	AS pd	ON pd.ProductDescriptionID = pv.ProductDescriptionID


-- Recreate the vector index
CREATE VECTOR INDEX ProductVectorDiskANNIndex 
	ON Production.ProductVector (ProductVector)
	WITH (
		METRIC = 'cosine',
		TYPE = 'diskann',
		MAXDOP = 8
	)
GO
