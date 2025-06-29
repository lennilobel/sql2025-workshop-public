/* =================== JSON Indexes =================== */

USE MyDB
GO

-- Generate 10000 rows
--TRUNCATE TABLE Customer

--;WITH GenerateOrdersCte AS (
--    SELECT CustomerId = value
--    FROM GENERATE_SERIES(10001, 20000)
--)
--INSERT INTO Customer
--SELECT 
--  CustomerId,
--  'SO-' + FORMAT(CustomerId, '00000'),
--  CASE WHEN CustomerId % 2 = 0 THEN
--    '
--      {
--        "customer": "Contoso",
--        "customerId": ' || CAST(CustomerId AS int) || ',
--        "orders": [
--          { "productId": 712, "quantity": 2 },
--          { "productId": 937, "quantity": 1 }
--        ],
--        "balance": 25.99,
--        "status": "processing",
--        "basket": {
--          "status": "PENDING",
--          "lastUpdated": "2025-06-07T07:32:00Z"
--        },
--        "preferred": false
--      }
--    '
--  ELSE
--    '
--      {
--        "customer": "Acme",
--        "customerId": ' || CAST(CustomerId AS int) || ',
--        "orders": [
--          { "productId": 894, "quantity": 5 },
--          { "productId": 3001, "quantity": 1 }
--        ],
--        "balance": 99.95,
--        "status": "processing",
--        "basket": {
--          "status": "DEAD",
--          "lastUpdated": "2025-05-18T13:18:00Z"
--        },
--        "preferred": false
--      }
--    '
--  END
--FROM
--  GenerateOrdersCte
  
SELECT * FROM Customer

-- Before 2025, we could only index scalar properties by creating and then indexing computed columns with JSON_VALUE
ALTER TABLE Customer
 ADD BasketStatus AS JSON_VALUE(CustomerJson, '$.basket.status')
GO

CREATE INDEX IX_Order_BasketStatus
 ON Customer(BasketStatus)

SELECT * FROM Customer
WHERE BasketStatus = 'PENDING'

DROP INDEX IX_Order_BasketStatus
 ON Customer

ALTER TABLE Customer
 DROP COLUMN BasketStatus


-- Now we have native JSON indexes that can point either scalar or complex (nested object/array) properties

-- Create a JSON index that covers the basket property (and all nested properties)
CREATE JSON INDEX IX_Customer_CustomerJson_Basket
ON Customer (CustomerJson)
FOR ('$.basket')

GO

SELECT * FROM sys.indexes WHERE type = 9
SELECT * FROM sys.json_index_paths

-- Execution plan shows no index being used; we must explicitly reference the index with a hint
--  (CTP note: the heuristics for using rowcount and statistics to pick a JSON index for query plan is not complete)
SELECT *
FROM Customer
WHERE JSON_VALUE(CustomerJson, '$.basket.status') = 'PENDING'

-- This query will leverage the JSON index
--  (CTP note: the index hint is required for now, but in the future it will be automatically picked up by the query optimizer)
SELECT *
FROM Customer WITH (INDEX (IX_Customer_CustomerJson_Basket))
WHERE JSON_VALUE(CustomerJson, '$.basket.status') = 'PENDING'

-- This query generates an error because the JSON index it references does not cover the JSON property being queried ($.status)
/*
SELECT *
FROM Customer WITH (INDEX (IX_Customer_CustomerJson_Basket))
WHERE JSON_VALUE(CustomerJson, '$.status') = 'processing'
*/

-- Only one JSON index can be created per table, so we must drop the previous one before creating a new one
DROP INDEX IX_Customer_CustomerJson_Basket ON Customer
GO

-- Create a JSON index that covers the entire JSON document (with all nested properties)
CREATE JSON INDEX IX_Customer_CustomerJson_All
ON Customer (CustomerJson)
FOR ('$')

GO

SELECT * FROM sys.indexes WHERE type = 9
SELECT * FROM sys.json_index_paths

-- The JSON index will be leveraged for any query that references any property in the JSON document
SELECT *
FROM Customer WITH (INDEX (IX_Customer_CustomerJson_All))
WHERE JSON_VALUE(CustomerJson, '$.status') = 'processing'

SELECT *
FROM Customer WITH (INDEX (IX_Customer_CustomerJson_All))
WHERE JSON_VALUE(CustomerJson, '$.basket.status') = 'PENDING'

DROP INDEX IX_Customer_CustomerJson_All ON Customer
GO
