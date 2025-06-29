/* AI: AdventureWorks: External AI Models - Refactor Stored Procedures for External Model */

USE AdventureWorks2022
GO

-- Refactor SearchProductsKNN to use the external model
ALTER PROCEDURE SearchProductsKNN
	@QueryText		nvarchar(max),
	@MinStockLevel	smallint		= 100,
	@MaxDistance	decimal(19, 16)	= 0.2,
	@Top			int				= 20
AS
BEGIN

	DECLARE @QueryVector vector(1536)
	SELECT @QueryVector = AI_GENERATE_EMBEDDINGS(@QueryText USE MODEL ProductTextEmbeddingModel)	--	<- replaces EXEC VectorizeText

	;WITH ProductVectorCte AS (
		SELECT TOP (@Top)
			ProductID,
			ProductDescriptionID,
			Distance = VECTOR_DISTANCE('cosine', ProductVector, @QueryVector)
		FROM
			Production.ProductVector
		ORDER BY
			Distance 
	)
	SELECT
		ProductName			= p.Name,
		ProductDescription	= pd.Description,
		p.SafetyStockLevel,
		pv.Distance
	FROM 
		ProductVectorCte							AS pv
		INNER JOIN Production.Product				AS p	ON p.ProductID = pv.ProductID
		INNER JOIN Production.ProductDescription	AS pd	ON pd.ProductDescriptionID = pv.ProductDescriptionID
	WHERE
		pv.Distance < @MaxDistance AND
		p.SafetyStockLevel >= @MinStockLevel
	ORDER BY    
		pv.Distance

END
GO

-- Refactor SearchProductsANN to use the external model
ALTER PROCEDURE SearchProductsANN
	@QueryText		nvarchar(max),
	@MinStockLevel	smallint		= 100,
	@MaxDistance	decimal(19, 16)	= 0.2,
	@Top			int				= 20
AS
BEGIN

	DECLARE @QueryVector vector(1536)
	SELECT @QueryVector = AI_GENERATE_EMBEDDINGS(@QueryText USE MODEL ProductTextEmbeddingModel)	--	<- replaces EXEC VectorizeText

	SELECT
		ProductName			= p.Name,
		ProductDescription	= pd.Description,
		p.SafetyStockLevel,
		pvs.Distance
	FROM
		VECTOR_SEARCH(
			TABLE		= Production.ProductVector	AS pvt,
			COLUMN		= ProductVector,
			SIMILAR_TO	= @QueryVector,
			METRIC		= 'cosine',
			TOP_N		= @top
		)											AS pvs
		INNER JOIN Production.ProductVector			AS pv	ON pvt.ProductVectorID = pv.ProductVectorID
		INNER JOIN Production.Product				AS p	ON pv.ProductID = p.ProductID
		INNER JOIN Production.ProductDescription	AS pd	ON pd.ProductDescriptionID = pv.ProductDescriptionID
	WHERE
		pvs.Distance < @MaxDistance AND
		p.SafetyStockLevel >= @MinStockLevel
	ORDER BY
		pvs.distance

END
GO

-- Retest the stored procedures that are now using the external model for vectorization
EXEC SearchProductsKNN 'Show me the best products for riding on rough ground'
EXEC SearchProductsANN 'Show me the best products for riding on rough ground'

EXEC SearchProductsKNN 'Recommend a bike that is good for riding around the city'
EXEC SearchProductsANN 'Recommend a bike that is good for riding around the city'
