/* AI: AdventureWorks: Basic Vector Search - Create SearchProductsKNN Stored Procedure */

USE AdventureWorks2022
GO

-- The stored procedure executes a hybrid KNN (exact) vector search using VECTOR_DISTANCE() combined with traditional search
CREATE PROCEDURE SearchProductsKNN
	@QueryText		nvarchar(max),
	@MinStockLevel	smallint		= 100,
	@MaxDistance	decimal(19, 16)	= 0.2,
	@Top			int				= 20
AS
BEGIN

	DECLARE @QueryVector vector(1536)
	EXEC VectorizeText @QueryText, @QueryVector OUTPUT

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

-- Test the stored procedure
EXEC SearchProductsKNN 'Show me the best products for riding on rough ground'
EXEC SearchProductsKNN 'Recommend a bike that is good for riding around the city'
EXEC SearchProductsKNN 'Looking for budget-friendly gear for beginners just getting into cycling'
EXEC SearchProductsKNN 'What''s best for long-distance rides with storage for travel gear?'
EXEC SearchProductsKNN 'Do you have any yellow or red bikes?'
EXEC SearchProductsKNN 'Do you have any yellow or red apples?'
EXEC SearchProductsKNN 'Do you have any yellow or red apples?', @MaxDistance = 0.3
