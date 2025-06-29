/* =================== JSON Path Array Wildcards and Ranges =================== */

USE MyDB
GO

-- How many credit cards does each customer have?

-- The JSON_ARRAY_LENGTH function returns is not (yet?) supported in SQL Server 2025
/*
SELECT
    CustomerId,
    CreditCardCount = JSON_ARRAY_LENGTH(CustomerJson, '$.creditCards')
FROM
    Customer
*/

-- So we need to use OPENJSON to count the number of elements in the array (very hackey)
SELECT
    CustomerId,
    CreditCardCount = (SELECT COUNT(*) FROM OPENJSON(CustomerJson, '$.creditCards'))
FROM
    Customer


-- Before SQL Server 2025, array references in JSON path expressions were very limited
SELECT
    CustomerId,
    AllCreditCards              = JSON_QUERY(e.CustomerJson, '$.creditCards'),
    FirstCreditCard             = JSON_QUERY(e.CustomerJson, '$.creditCards[0]'),
    FirstCreditCardType         = JSON_VALUE(e.CustomerJson, '$.creditCards[0].type'),
    SecondCreditCard            = JSON_QUERY(e.CustomerJson, '$.creditCards[1]'),
    SecondCreditCardType        = JSON_VALUE(e.CustomerJson, '$.creditCards[1].type')
FROM
    Customer AS e

-- SQL Server 2025 supports array wildcard and range references with JSON_QUERY, JSON_PATH_EXISTS, and JSON_CONTAINS

SELECT
    CustomerId,
    -- Before SQL Server 2025, array references in JSON path expressions were very limited
    AllCreditCardsBad           = JSON_QUERY(e.CustomerJson, '$.creditCards[*]'),
    AllCreditCards              = JSON_QUERY(e.CustomerJson, '$.creditCards[*]' WITH ARRAY WRAPPER),
    AllCreditCardTypes          = JSON_QUERY(e.CustomerJson, '$.creditCards[*].type' WITH ARRAY WRAPPER),
    FirstThreeCreditCardTypes   = JSON_QUERY(e.CustomerJson, '$.creditCards[0 to 2].type' WITH ARRAY WRAPPER),
    LastCreditCardType          = JSON_VALUE(e.CustomerJson, '$.creditCards[last].type'),
    FirstAndLastCreditCardType  = JSON_QUERY(e.CustomerJson, '$.creditCards[0, last].type' WITH ARRAY WRAPPER),
    LastAndFirstCreditCardType  = JSON_QUERY(e.CustomerJson, '$.creditCards[last, 0].type' WITH ARRAY WRAPPER),
    EveryOtherCreditCardType    = JSON_QUERY(e.CustomerJson, '$.creditCards[0, 2, 4, 6, 8].type' WITH ARRAY WRAPPER)
FROM
    Customer AS e
