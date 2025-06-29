/* =================== json.modify Method =================== */

USE MyDB
GO

SELECT * FROM Customer WHERE CustomerId = 1002

-- Change preferred property from false to true
UPDATE Customer
SET CustomerJson.modify('$.preferred', 'true')
WHERE CustomerId = 1002

-- Change basket status property from PENDING to DEAD (shortening a string will perform 'in-place modification' internally)
UPDATE Customer
SET CustomerJson.modify('$.basket.status', 'DEAD')
WHERE CustomerId = 1002

SELECT * FROM Customer WHERE CustomerId = 1002

-- Create new priority property 
UPDATE Customer
SET CustomerJson.modify('$.priority', 'high')
WHERE CustomerId = 1002

SELECT * FROM Customer WHERE CustomerId = 1002

-- Change customer name to a longer name (can't perform in-place modification internally)
UPDATE Customer
SET CustomerJson.modify('$.customerName', 'Jane Susan Smith')
WHERE CustomerId = 1002

SELECT * FROM Customer WHERE CustomerId = 1002

-- Change customer name to a shorter name (can perform in-place modification internally)
UPDATE Customer
SET CustomerJson.modify('$.customerName', 'Amy Ling')
WHERE CustomerId = 1002

SELECT * FROM Customer WHERE CustomerId = 1002

-- Remove an existing field
UPDATE Customer
SET CustomerJson.modify('$.priority', NULL)
WHERE CustomerId = 1002

SELECT * FROM Customer WHERE CustomerId = 1002

-- There seems to be no way to set a field to null in the JSON; all you can do is remove it, which sets its value to undefined
UPDATE Customer
SET CustomerJson.modify('$.preferred', 'null')	-- sets preferred to the string value 'null', not an actual null
WHERE CustomerId = 1002

SELECT * FROM Customer WHERE CustomerId = 1002
