/* Change Event Streaming - Generate Events */

USE CesDemo
GO

-- View initial data
SELECT * FROM Customer
SELECT * FROM Product
SELECT * FROM [Order]
SELECT * FROM OrderDetail
SELECT * FROM TableWithNoPK

-- *** Start the CESClient to watch events as they occur! ***

-- Create an order
EXEC CreateOrder @CustomerId = 1

-- Add two order details
--  Note: Each INSERT into the OrderDetail table triggers an UPDATE to a corresponding row in the Product table, resulting in two CES events being generated
EXEC CreateOrderDetail @OrderId = 1, @ProductId = 1, @Quantity = 2
EXEC CreateOrderDetail @OrderId = 1, @ProductId = 2, @Quantity = 1

-- Delete the order (and its order details)
--  Note: Each DELETE from the OrderDetail table triggers an UPDATE to a corresponding row in the Product table, resulting in two CES events being generated
EXEC DeleteOrder @OrderId = 1

-- Change the customer city
--  Note: This table is not tracking old values, but is including "all columns"
UPDATE Customer SET City = 'New Mexico' WHERE CustomerId = 1

-- Batch update products
--  Note: Even though we are not tracking "all columns", the PK is always included
UPDATE Product SET UnitPrice = UnitPrice * 0.8 WHERE Category = 'Camera'

-- Batch delete products
DELETE FROM Product WHERE Color = 'Black'

-- With no PK on the table, and and not including "all columns", only the changed value will be sent; without a PK, this is useless
UPDATE TableWithNoPK SET ItemName = 'Stove' WHERE Id = 3

DELETE FROM TableWithNoPK WHERE Id IN (1, 3)

-- Check for any errors
SELECT * FROM sys.dm_change_feed_errors ORDER BY entry_time DESC
