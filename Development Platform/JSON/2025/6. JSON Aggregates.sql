/* =================== JSON Path Expression Array Enhancements =================== */

USE MyDB
GO

DROP TABLE IF EXISTS Customer
DROP TABLE IF EXISTS Account
GO

CREATE TABLE Account (
	AccountNumber varchar(10) NOT NULL PRIMARY KEY,
	Phone1 varchar(20),
	Phone2 varchar(20),
	Phone3 varchar(20)
)

INSERT INTO Account VALUES
  ('AW29825', '(123) 456-7890', '(123) 567-8901', NULL),
  ('AW73565', '(234) 987-6543', NULL,             NULL)

CREATE TABLE Customer (
	CustomerId     varchar(10) NOT NULL PRIMARY KEY,
	OrderTime       datetime2,
	AccountNumber   varchar(10) REFERENCES Account (AccountNumber),
	Price           decimal(10, 2),
	Quantity        int
)
GO

-- Input JSON document containing a JSON array where each element is a JSON object
DECLARE @OrdersJson json = '
[
    {
        "CustomerId": "S043659",
        "Date":"2022-05-24T08:01:00",
        "AccountNumber":"AW29825",
        "Price":59.99,
        "Quantity":1
    },
    {
        "CustomerId": "S043661",
        "Date":"2022-05-20T12:20:00",
        "AccountNumber":"AW73565",
        "Price":24.99,
        "Quantity":3
    }
]'

INSERT INTO Customer
SELECT
    CustomerId     = JSON_VALUE(value, '$.CustomerId'),
    OrderTime       = JSON_VALUE(value, '$.Date'),
    AccountNumber   = JSON_VALUE(value, '$.AccountNumber'),
    Price           = JSON_VALUE(value, '$.Price'),
    Quantity        = JSON_VALUE(value, '$.Quantity')
FROM
    OPENJSON(@OrdersJson)
GO

SELECT * FROM Customer
SELECT * FROM Account


-- JSON_OBJECTAGG

SELECT
    *
FROM
    Customer AS o
    INNER JOIN Account AS a ON a.AccountNumber = o.AccountNumber

SELECT
    JSON_OBJECT(
        'CustomerId': o.CustomerId,
        'Date': o.OrderTime,
        'Price': o.Price,
        'Quantity': o.Quantity, 
        'AccountDetails': JSON_OBJECT(
            'AccountNumber': o.AccountNumber,
            'PhoneNumbers': JSON_ARRAY(
                a.Phone1,
                a.Phone2,
                a.Phone3
            )
        )
    )    
FROM
    Customer AS o
    INNER JOIN Account AS a ON a.AccountNumber = o.AccountNumber

SELECT
    JSON_OBJECTAGG(CustomerId:
        JSON_OBJECT(
            'CustomerId': o.CustomerId,
            'Date': o.OrderTime,
            'Price': o.Price,
            'Quantity': o.Quantity, 
            'AccountDetails': JSON_OBJECT(
                'AccountNumber': o.AccountNumber,
                'PhoneNumbers': JSON_ARRAY(
                    a.Phone1,
                    a.Phone2,
                    a.Phone3
                )
            )
        )    
    )
FROM
    Customer AS o
    INNER JOIN Account AS a ON a.AccountNumber = o.AccountNumber


-- JSON_ARRAYAGG

SELECT
    JSON_ARRAY(
        a.Phone1,
        a.Phone2,
        a.Phone3
    ) AS Phones
  FROM
    Customer AS o
    INNER JOIN Account AS a ON a.AccountNumber = o.AccountNumber

SELECT
    AccountNumber,
    JSON_ARRAY(
        Phone1,
        Phone2,
        Phone3
    ) AS Phones
  FROM
    Account

SELECT
    JSON_ARRAYAGG(
        JSON_ARRAY(
            Phone1,
            Phone2,
            Phone3
        )
    ) AS Phones
  FROM
    Account


-- More JSON aggregates

GO

DROP TABLE IF EXISTS SampleData

CREATE TABLE SampleData (
    Category int,
    Name varchar(10),
    Type varchar(10),
    Amount int
)

INSERT INTO SampleData VALUES
 (1, 'Item 1.1', 'TypeA', 100),
 (1, 'Item 1.2', 'TypeB', 200),
 (1, 'Item 1.3', 'TypeB', 300),
 (2, 'Item 2.1', 'TypeD', 400),
 (2, 'Item 2.2', 'TypeD', 500)

SELECT * FROM SampleData

SELECT
    AllAmountsArray         = JSON_ARRAYAGG(Amount),
    AllAmountsObjectByName  = JSON_OBJECTAGG(Name:Amount),
    AllAmountsTotal         = SUM(Amount)
FROM
    SampleData


-- JSON aggregates with GROUP BY

SELECT
    Category,
    CategoryAmountsArray        = JSON_ARRAYAGG(Amount),
    CategoryAmountsObjectByName = JSON_OBJECTAGG(Name:Amount),
    CategoryAmountsTotal        = SUM(Amount)
FROM
    SampleData
GROUP BY
    Category

SELECT
    Category,
    Type,
    CategoryAndTypeAmountsArray         = JSON_ARRAYAGG(Amount),
    CategoryAndTypeAmountsObjectByName  = JSON_OBJECTAGG(Name:Amount),
    CategoryAndTypeAmountsTotal         = SUM(Amount)
FROM
    SampleData
GROUP BY
    Category,
    Type


-- JSON aggregates with OVER

SELECT
    Category,
    Type,
    CategoryAmountsArray        = JSON_ARRAYAGG(Amount)         OVER (PARTITION BY Category),
    CategoryAmountsObjectByName = JSON_OBJECTAGG(Name:Amount)   OVER (PARTITION BY Category),
    CategoryAmountsTotal        = SUM(Amount)                   OVER (PARTITION BY Category)
FROM
    SampleData


-- JSON aggregates with GROUPING SETS

SELECT
    Category,
    Type,
    GroupAmountsArray        = JSON_ARRAYAGG(Amount),
    GroupAmountsObjectByName = JSON_OBJECTAGG(Name:Amount),
    GroupAmountsTotal        = SUM(Amount)
FROM
    SampleData
GROUP BY
    GROUPING SETS(
        (Category),         -- Group by Category only
        (Type),             -- Group by Type only
        (Category, Type),   -- Group by both Category and Type
        ()                  -- No GROUP BY (grand balance)
    )
ORDER BY
    Category,
    Type


-- Clean up
DROP TABLE SampleData
DROP TABLE IF EXISTS Customer
DROP TABLE IF EXISTS Account
