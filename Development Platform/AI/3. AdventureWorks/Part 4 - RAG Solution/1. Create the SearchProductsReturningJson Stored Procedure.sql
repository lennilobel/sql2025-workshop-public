/* AI: AdventureWorks: RAG Solition - Create AskProductQuestion Stored Procedure */

USE AdventureWorks2022
GO

CREATE OR ALTER PROCEDURE SearchProductsReturningJson
  @QueryText      nvarchar(max),
  @JsonResults    nvarchar(max) OUTPUT
AS
BEGIN

  DECLARE @Results TABLE (
    ProductName         nvarchar(max),
    ProductDescription  nvarchar(max),
    SafetyStockLevel    smallint,
    Distance            decimal(19, 16)
  )

  INSERT INTO @Results
  EXEC SearchProductsANN
    @QueryText     = @QueryText,
    @MinStockLevel = 100,
    @MaxDistance   = .2,
    @Top           = 20

  SELECT @JsonResults = (
    SELECT
      ProductName,
      ProductDescription
    FROM
      @Results
    FOR JSON AUTO
  )

END
GO

DECLARE @JsonResults nvarchar(max)
EXEC SearchProductsReturningJson 'Show me the best products for riding on rough ground', @JsonResults OUTPUT
SELECT @JsonResults
GO
