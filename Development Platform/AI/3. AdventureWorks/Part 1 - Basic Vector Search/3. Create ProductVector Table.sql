/* AI: AdventureWorks: Basic Vector Search - Create ProductVector Table */

USE AdventureWorks2022
GO

CREATE TABLE Production.ProductVector (
	ProductVectorID			int IDENTITY NOT NULL,
	ProductID				int NOT NULL,
	ProductDescriptionId	int NOT NULL,
	ProductVector			vector(1536),

	CONSTRAINT PK_ProductVector			PRIMARY KEY CLUSTERED (ProductVectorID),
	CONSTRAINT FK_Product				FOREIGN KEY (ProductID) REFERENCES Production.Product(ProductID),
	CONSTRAINT FK_ProductDescription	FOREIGN KEY (ProductDescriptionID) REFERENCES Production.ProductDescription(ProductDescriptionID),
)
GO

INSERT INTO Production.ProductVector (ProductID, ProductDescriptionID)
SELECT
	p.ProductID,
	pd.ProductDescriptionID
FROM
	Production.Product											AS p
	INNER JOIN Production.ProductModel							AS pm		ON pm.ProductModelID = p.ProductModelID
	INNER JOIN Production.ProductModelProductDescriptionCulture	AS pmpdc	ON pmpdc.ProductModelID = pm.ProductModelID
	INNER JOIN Production.ProductDescription					AS pd		ON pd.ProductDescriptionID = pmpdc.ProductDescriptionID
WHERE
	pmpdc.CultureID = 'en'	-- Only get English descriptions to keep the dataset small, but we could use all cultures and support natural-language queries in all languages

-- Examine the product vector table not yet populated with vectors
SELECT * FROM Production.ProductVector
