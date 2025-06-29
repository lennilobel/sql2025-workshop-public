/* Change Event Streaming - Cleanup */

USE CesDemo
GO

-- Note: A database cannot be dropped if it has active streaming groups and objects

-- Remove tables from streaming group
EXEC sys.sp_remove_object_from_event_stream_group 'SqlCesGroup', 'dbo.Product'
EXEC sys.sp_remove_object_from_event_stream_group 'SqlCesGroup', 'dbo.Customer'
EXEC sys.sp_remove_object_from_event_stream_group 'SqlCesGroup', 'dbo.Order'
EXEC sys.sp_remove_object_from_event_stream_group 'SqlCesGroup', 'dbo.OrderDetail'
EXEC sys.sp_remove_object_from_event_stream_group 'SqlCesGroup', 'dbo.TableWithNoPK'

-- Drop tables
DROP TABLE OrderDetail
DROP TABLE [Order]
DROP TABLE Product
DROP TABLE Customer
DROP TABLE TableWithNoPK

-- Drop stream group and disable CES
EXEC sys.sp_drop_event_stream_group 'SqlCesGroup'
EXEC sys.sp_disable_event_stream

-- Delete database
USE master

-- Set the database to single user mode
ALTER DATABASE CesDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE

-- Drop the database
DROP DATABASE CesDemo
