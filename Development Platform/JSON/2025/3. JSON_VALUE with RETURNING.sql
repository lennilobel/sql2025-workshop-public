/* =================== JSON_VALUE with RETURNING =================== */

USE MyDB
GO

-- Throws error because the JSON_VALUE function return nvarchar by default, and so the numeric > operator fails
IF 1 = 0
    SELECT * FROM Customer WHERE JSON_VALUE(CustomerJson, '$.balance') > 50.5

-- Convert nvarchar to money data type using CAST or CONVERT
SELECT * FROM Customer WHERE CAST(JSON_VALUE(CustomerJson, '$.balance') AS money) > 50.5

-- Now we can use the (ANSI-compliant) RETURNING clause, but only for integer types
SELECT * FROM Customer WHERE JSON_VALUE(CustomerJson, '$.balance' RETURNING int) > 50
