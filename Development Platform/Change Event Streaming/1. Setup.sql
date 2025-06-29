/* Change Event Streaming - Setup */

-- Create the demo database
USE master
GO

CREATE DATABASE CesDemo
GO

USE CesDemo
GO

-- Create the database master key
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
  CREATE MASTER KEY ENCRYPTION BY PASSWORD = '[PASSWORD]'

-- Create the credential that will be used to access the Azure Event Hub Namespace via a Shared Access Signature (SAS) token
CREATE DATABASE SCOPED CREDENTIAL SqlCesCredential
WITH
  IDENTITY = 'SHARED ACCESS SIGNATURE',
  SECRET = '[SECRET]'

-- Create some demo tables
CREATE TABLE Customer (
  CustomerId    int IDENTITY PRIMARY KEY,
  CustomerName  varchar(50),
  City          varchar(20)
)
GO

SET IDENTITY_INSERT Customer ON
INSERT INTO Customer
  (CustomerId,  CustomerName,               City) VALUES
  (1,           'Shutter Bros Wholesale',   'New York'),
  (2,           'Aperture Supply Co.',      'Los Angeles')
SET IDENTITY_INSERT Customer OFF

CREATE TABLE Product (
  ProductId     int IDENTITY PRIMARY KEY,
  Name          varchar(80),
  Color         varchar(15),
  Category      varchar(20),
  UnitPrice     decimal(8, 2),
  ItemsInStock  smallint
)
GO

SET IDENTITY_INSERT Product ON
INSERT INTO Product
  (ProductId,   Name,                                   Color,      Category,       UnitPrice,  ItemsInStock) VALUES 
  (1,           'Canon EOS R5 Mirrorless Camera',       'Black',    'Camera',       3899.99,    10),
  (2,           'Nikon Z6 II Mirrorless Camera',        'Silver',   'Camera',       1996.95,    8),
  (3,           'Sony NP-FZ100 Rechargeable Battery',   'Black',    'Accessory',    78.00,      25)
SET IDENTITY_INSERT Product OFF

CREATE TABLE [Order] (
  OrderId       int IDENTITY PRIMARY KEY,
  CustomerId    int REFERENCES Customer(CustomerId),
  OrderDate     datetime2
)
GO

CREATE TABLE OrderDetail (
  OrderDetailId int IDENTITY PRIMARY KEY,
  OrderId       int REFERENCES [Order](OrderId),
  ProductId     int REFERENCES Product(ProductId),
  Quantity      smallint
)
GO

-- This table lacks Primary Key. Combining that with IncludeAllColumns = 0 results in events that have no primary key, which is essentially useless
CREATE TABLE TableWithNoPK (
  Id        int IDENTITY,
  ItemName  varchar(50)
)
GO

INSERT INTO TableWithNoPK (ItemName) VALUES
  ('Camera'),
  ('Automobile'),
  ('Oven'),
  ('Couch')
GO

-- Create a DML trigger on OrderDetail that updates the ItemsInStock column in the Product table based on the Quantity column in the OrderDetail table
CREATE TRIGGER trgUpdateItemsInStock ON OrderDetail AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  -- Handle insert
  IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    UPDATE Product
    SET ItemsInStock = p.ItemsInStock - i.Quantity
    FROM
      Product AS p
      INNER JOIN inserted AS i ON p.ProductId = i.ProductId

  -- Handle update
  ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) AND UPDATE(Quantity)
    UPDATE Product
    SET ItemsInStock = p.ItemsInStock + d.Quantity - i.Quantity
    FROM
      Product AS p
      INNER JOIN inserted AS i ON p.ProductId = i.ProductId
      INNER JOIN deleted AS d ON p.ProductId = d.ProductId

  -- Handle delete
  ELSE IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    UPDATE Product
    SET ItemsInStock = p.ItemsInStock + d.Quantity
    FROM
      Product AS p
      INNER JOIN deleted AS d ON p.ProductId = d.ProductId
END
GO

-- Add some procs to handle orders
CREATE OR ALTER PROC CreateOrder
  @CustomerId int
AS
BEGIN
  INSERT INTO [Order](CustomerId, OrderDate)
  VALUES (@CustomerId, SYSDATETIME())

  SELECT OrderId = SCOPE_IDENTITY()
END
GO

CREATE OR ALTER PROC CreateOrderDetail
  @OrderId int,
  @ProductId int,
  @Quantity smallint
AS
BEGIN
  INSERT INTO OrderDetail (OrderId, ProductId, Quantity)
  VALUES (@OrderId, @ProductId, @Quantity)

  SELECT OrderDetailId = SCOPE_IDENTITY()
END
GO

CREATE OR ALTER PROC DeleteOrder
  @OrderId int
AS
BEGIN
  BEGIN TRANSACTION
    DELETE FROM OrderDetail WHERE OrderId = @OrderId
    DELETE FROM [Order] WHERE OrderId = @OrderId
  COMMIT TRANSACTION
END
GO
