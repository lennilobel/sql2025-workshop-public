/* =================== Storing and Querying JSON =================== */

USE MyDB
GO

/*** ISJSON ***/

DECLARE @JsonData AS nvarchar(max) = N'
[
	{
		"OrderId": 5,
		"CustomerId: 6,
		"OrderDate": "2015-10-10T14:22:27.25-05:00",
		"OrderAmount": 25.9
	},
	{
		"OrderId": 29,
		"CustomerId": 76,
		"OrderDate": "2015-12-10T11:02:36.12-08:00",
		"OrderAmount": 350.25
	}
]'

SELECT ISJSON(@JsonData)	-- Returns false because of missing closing quote on CustomerId property
GO


/*** Store JSON orders data in a table ***/

DROP TABLE IF EXISTS OrdersJson

CREATE TABLE OrdersJson(
 	OrdersId int PRIMARY KEY, 
	OrdersDoc varchar(max) NOT NULL DEFAULT '[]',
    CONSTRAINT CK_OrdersJson_OrdersDoc CHECK (ISJSON(OrdersDoc) = 1)
)

DECLARE @JsonData AS varchar(max) = '
[
	{
		"OrderId": 5,
		"CustomerId: 6,
		"OrderDate": "2015-10-10T14:22:27.25-05:00",
		"OrderAmount": 25.9
	},
	{
		"OrderId": 29,
		"CustomerId": 76,
		"OrderDate": "2015-12-10T11:02:36.12-08:00",
		"OrderAmount": 350.25
	}
]'

INSERT INTO OrdersJson(OrdersId, OrdersDoc) VALUES (1, @JsonData)	-- Fails because of missing closing quote on CustomerId property

INSERT INTO OrdersJson(OrdersId) VALUES (2)	-- Accepts default empty array

SELECT * FROM OrdersJson

UPDATE OrdersJson SET OrdersDoc = JSON_MODIFY(OrdersDoc, '$[1].OrderAmount', 999) WHERE OrdersId = 1

SELECT * FROM OrdersJson


/*** Store JSON book data in a table for querying ***/

CREATE TABLE BooksJson(
 	BookId int PRIMARY KEY, 
	BookDoc varchar(max) NOT NULL,
    CONSTRAINT CK_BooksJson_BookDoc CHECK (ISJSON(BookDoc) = 1)
)

INSERT INTO BooksJson VALUES (1, '
	{
		"category": "ITPro",
		"title": "Programming SQL Server",
		"author": "Lenni Lobel",
		"price": {
			"amount": 49.99,
			"currency": "USD"
		},
		"purchaseSites": [
			"amazon.com",
			"booksonline.com"
		]
	}
')

INSERT INTO BooksJson VALUES (2, '
	{
		"category": "Developer",
		"title": "Developing ADO .NET",
		"author": "Andrew Brust",
		"price": {
			"amount": 39.93,
			"currency": "USD"
		},
		"purchaseSites": [
			"booksonline.com"
		]
	}
')

INSERT INTO BooksJson VALUES (3, '
	{
		"category": "ITPro",
		"title": "Windows Cluster Server",
		"author": "Stephen Forte",
		"price": {
			"amount": 59.99,
			"currency": "CAD"
		},
		"purchaseSites": [
			"amazon.com"
		]
	}
')

SELECT * FROM BooksJson


/*** JSON_VALUE ***/

-- Get all ITPro books
SELECT *
 FROM BooksJson
 WHERE JSON_VALUE(BookDoc, '$.category') = 'ITPro'

-- Index the category property
ALTER TABLE BooksJson
 ADD BookCategory AS JSON_VALUE(BookDoc, '$.category')

CREATE INDEX IX_BooksJson_BookCategory
 ON BooksJson(BookCategory)

SELECT *
 FROM BooksJson
 WHERE BookCategory = 'ITPro'

-- Extract other properties
SELECT
	BookId,
	JSON_VALUE(BookDoc, '$.category') AS Category,
	JSON_VALUE(BookDoc, '$.title') AS Title,
	JSON_VALUE(BookDoc, '$.price.amount') AS PriceAmount,
	JSON_VALUE(BookDoc, '$.price.currency') AS PriceCurrency
 FROM
	BooksJson


/*** JSON_QUERY ***/

SELECT
	BookId,
	JSON_VALUE(BookDoc, '$.category') AS Category,
	JSON_VALUE(BookDoc, '$.title') AS Title,
	JSON_VALUE(BookDoc, '$.price.amount') AS PriceAmount,
	JSON_VALUE(BookDoc, '$.price.currency') AS PriceCurrency,
	JSON_QUERY(BookDoc, '$.purchaseSites') AS PurchaseSites
 FROM
	BooksJson

-- Cleanup
DROP TABLE IF EXISTS OrdersJson
DROP TABLE IF EXISTS BooksJson
GO
