/* =================== Native JSON Data Type =================== */

--  https://learn.microsoft.com/en-us/sql/t-sql/data-types/json-data-type?view=azuresqldb-current&viewFallbackFrom=sql-server-ver17

USE MyDB
GO

-- Create a table with a JSON column
DROP TABLE IF EXISTS Customer
GO

CREATE TABLE Customer
(
  CustomerId    int PRIMARY KEY,
  CustomerJson  json
)
GO

-- Try to populate with invalid JSON; you can't, so no need for CHECK constraints using ISJSON any more
IF 1 = 0
    INSERT INTO Customer VALUES (1001, '{ "bad JSON!')

-- Add two customers using OPENJSON
DECLARE @CustomerJson json = '
  [
    {
      "customerName": "John Doe",
      "customerId": 1001,
      "orders": [
        { "productId": 712, "quantity": 2 },
        { "productId": 937, "quantity": 1 },
        { "productId": 101, "quantity": 4 },
        { "productId": 214, "quantity": 7 },
        { "productId": 325, "quantity": 1 },
        { "productId": 476, "quantity": 5 },
        { "productId": 583, "quantity": 3 },
        { "productId": 699, "quantity": 2 },
        { "productId": 805, "quantity": 6 },
        { "productId": 912, "quantity": 1 },
        { "productId": 1033, "quantity": 8 },
        { "productId": 1144, "quantity": 2 },
        { "productId": 1205, "quantity": 4 },
        { "productId": 1310, "quantity": 3 },
        { "productId": 1458, "quantity": 5 },
        { "productId": 1520, "quantity": 6 },
        { "productId": 1629, "quantity": 1 },
        { "productId": 1740, "quantity": 7 },
        { "productId": 1833, "quantity": 2 },
        { "productId": 1902, "quantity": 4 },
        { "productId": 2011, "quantity": 8 },
        { "productId": 2155, "quantity": 3 },
        { "productId": 2288, "quantity": 5 },
        { "productId": 2390, "quantity": 2 },
        { "productId": 2401, "quantity": 1 },
        { "productId": 2533, "quantity": 6 },
        { "productId": 2689, "quantity": 3 },
        { "productId": 2754, "quantity": 7 },
        { "productId": 2861, "quantity": 8 },
        { "productId": 2977, "quantity": 2 },
        { "productId": 3050, "quantity": 4 },
        { "productId": 3198, "quantity": 1 }
      ],
      "creditCards": [
        {
          "type": "American Express",
          "number": "675984450768756054",
          "currency": "USD"
        },
        {
          "type": "Visa",
          "number": "3545138777072343",
          "currency": "USD"
        },
        {
          "type": "MasterCard",
          "number": "6397068371771473",
          "currency": "CAD"
        },
        {
          "type": "Discover",
          "number": "6011000990139424",
          "currency": "EUR"
        },
        {
          "type": "JCB",
          "number": "3530111333300000",
          "currency": "GBP"
        }
      ],
      "balance": 25.99,
      "status": "processing",
      "basket": {
        "status": "PENDING",
        "lastUpdated": "2025-06-07T07:32:00Z"
      },
      "preferred": false
    },
    {
      "customerName": "Jane Smith",
      "customerId": 1002,
      "orders": [
        { "productId": 894, "quantity": 5 },
        { "productId": 3001, "quantity": 1 }
      ],
      "creditCards": [
        {
          "type": "Visa",
          "number": "4111111111111111",
          "currency": "USD"
        },
        {
          "type": "MasterCard",
          "number": "5500000000000004",
          "currency": "CAD"
        }
      ],
      "balance": 99.95,
      "status": "processing",
      "basket": {
        "status": "PENDING",
        "lastUpdated": "2025-05-18T13:18:00Z"
      },
      "preferred": false
    }
  ]
'

INSERT INTO Customer
SELECT
    CustomerId = JSON_VALUE(e.value, '$.customerId'),
    CustomerJson = e.value
FROM
    OPENJSON(@CustomerJson) AS e

SELECT * FROM Customer

-- This JSON data has no unicode, so it's safe to use varchar for 8-bit ASCII
-- However, if we required unicode, we'd need to use nvarchar (for 16-bits per character; double the storage)
-- The new json data type supports unicode (16-bit characters), yet its compact binary storage is smaller than both unicode and non-unicode strings

DECLARE @JsonData_json      json            = (SELECT CustomerJson FROM Customer WHERE CustomerId = 1001)
DECLARE @JsonData_nvarchar  nvarchar(max)   = CAST(@JsonData_json AS nvarchar(max))
DECLARE @JsonData_varchar   varchar(max)    = CAST(@JsonData_json AS varchar(max))

-- Observe:
--   The unicode string version (nvarchar) is substantially larger than the new compact json binary format storage
--   Even without unicode support (varchar), the string version is notably larger than the native json data type
SELECT
  Length_json     = DATALENGTH(@JsonData_json),
  Length_nvarchar = DATALENGTH(@JsonData_nvarchar),
  Length_varchar  = DATALENGTH(@JsonData_varchar)

GO
