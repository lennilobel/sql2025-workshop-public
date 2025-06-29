/* AI: AdventureWorks: DiskANN Indexing - Create the SearchProductsANN stored procedure */

USE AdventureWorks2022
GO

-- The stored procedure executes a hybrid ANN (approximate) vector search using VECTOR_SEARCH() combined with traditional search
CREATE PROCEDURE SearchProductsANN
	@QueryText		nvarchar(max),
	@MinStockLevel	smallint		= 100,
	@MaxDistance	decimal(19, 16)	= 0.2,
	@Top			int				= 20
AS
BEGIN

	DECLARE @QueryVector vector(1536)
	EXEC VectorizeText @QueryText, @QueryVector OUTPUT

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

EXEC SearchProductsANN 'Show me the best products for riding on rough ground'
EXEC SearchProductsANN 'Recommend a bike that is good for riding around the city'
EXEC SearchProductsANN 'Looking for budget-friendly gear for beginners just getting into cycling'
EXEC SearchProductsANN 'What''s best for long-distance rides with storage for travel gear?'
EXEC SearchProductsANN 'Do you have any yellow or red bikes?'
EXEC SearchProductsANN 'Do you have any yellow or red apples?'
EXEC SearchProductsANN 'Do you have any yellow or red apples?', @MaxDistance = 0.3

-- Not enough data to appreciate DiskANN performance by including client statistics
EXEC SearchProductsKNN 'Show me the best products for riding on rough ground'
EXEC SearchProductsANN 'Show me the best products for riding on rough ground'
