/* =================== Shredding JSON =================== */

USE AdventureWorks2022
GO

/*** OPENJSON (simple example) ***/

-- Store books as JSON array
DECLARE @BooksJson varchar(max) = '
[
  {
    "category": "ITPro",
    "title": "Programming SQL Server",
    "author": "Lenni Lobel",
    "price": 49.99
  },
  {
    "category": "Developer",
    "title": "Developing ADO .NET",
    "author": "Andrew Brust",
    "price": 39.93
  },
  {
    "category": "ITPro",
    "title": "Windows Cluster Server",
    "author": "Stephen Forte",
    "price": 59.99
  }
]
'

-- Shred the JSON array into multiple rows
SELECT * FROM OPENJSON(@BooksJson)

-- Shred the JSON array into multiple rows with filtering and sorting
SELECT *
 FROM		OPENJSON(@BooksJson, '$') AS b
 WHERE		JSON_VALUE(b.value, '$.category') = 'ITPro'
 ORDER BY	JSON_VALUE(b.value, '$.author') DESC
	
-- Shred the properties of the first object in the JSON array into multiple rows
SELECT *
 FROM		OPENJSON(@BooksJson, '$[0]')

--	0 = null
--	1 = string
--	2 = int
--	3 = bool
--	4 = array
--  5 = object


/*** OPENJSON (parent/child example) ***/

-- Store a person with multiple contacts as JSON object
DECLARE @PersonJson varchar(max) = '
	{
		"Id": 236,
		"Name": {
			"FirstName": "John",
			"LastName": "Doe"
		},
		"Address": {
			"AddressLine": "137 Madison Ave",
			"City": "New York",
			"Province": "NY",
			"PostalCode": "10018"
		},
		"Contacts": [
			{
				"Type": "mobile",
				"Number": "917-777-1234"
			},
			{
				"Type": "home",
				"Number": "212-631-1234"
			},
			{
				"Type": "work",
				"Number": "212-635-2234"
			},
			{
				"Type": "fax",
				"Number": "212-635-2238"
			}
		]
	}
'

-- The header values can be extracted directly from the JSON source
SELECT
	PersonId		= JSON_VALUE(@PersonJson, '$.Id'),
	FirstName		= JSON_VALUE(@PersonJson, '$.Name.FirstName'),
	LastName		= JSON_VALUE(@PersonJson, '$.Name.LastName'),
	AddressLine		= JSON_VALUE(@PersonJson, '$.Address.AddressLine'),
	City			= JSON_VALUE(@PersonJson, '$.Address.City'),
	Province		= JSON_VALUE(@PersonJson, '$.Address.Province'),
	PostalCode		= JSON_VALUE(@PersonJson, '$.Address.PostalCode')

-- To produce multiple child rows for each contact, use OPENJSON
SELECT
	PersonId		= JSON_VALUE(@PersonJson, '$.Id'),	-- FK
	ContactType		= JSON_VALUE(c.value, '$.Type'),
	ContactNumber	= JSON_VALUE(c.value, '$.Number')
 FROM
	OPENJSON(@PersonJson, '$.Contacts') AS c


/*** OPENJSON (with schema) ***/

-- Store a batch of orders in JSON
DECLARE @OrdersJson Nvarchar(max) = '
{
  "BatchId": 442,
  "Orders": [
    {
      "OrderNumber": "SO43659",
      "OrderDate": "2011-05-31T00:00:00",
      "AccountNumber": "AW29825",
      "Item": {
        "Quantity": 1,
        "Price": 2024.9940
      }
    },
    {
      "OrderNumber": "SO43661",
      "OrderDate": "2011-06-01T00:00:00",
      "AccountNumber": "AW73565",
      "Item": {
        "Quantity": 3,
        "Price": 2024.9940
      }
    }
  ]
}
'

-- Query with default schema
SELECT *
 FROM OPENJSON (@OrdersJson, '$.Orders')

-- Query with explicit schema
SELECT *
 FROM OPENJSON (@OrdersJson, '$.Orders')
 WITH ( 
	OrderNumber	varchar(200),
	OrderDate	datetime,
	Customer	varchar(200)    '$.AccountNumber',
	Item		nvarchar(max)	'$.Item' AS JSON,
	Quantity	int				'$.Item.Quantity',
	Price		money			'$.Item.Price'
) 
