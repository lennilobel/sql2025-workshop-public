/* Change Event Streaming - Configure CES */

-- Enable CES
SELECT * FROM sys.databases WHERE is_event_stream_enabled = 1

EXEC sys.sp_enable_event_stream

SELECT * FROM sys.databases WHERE is_event_stream_enabled = 1

-- Create the Event Stream Group
EXEC sys.sp_create_event_stream_group
  @stream_group_name      = 'SqlCesGroup',
  @destination_location   = 'ces-namespace.servicebus.windows.net/ces-hub',
  @destination_credential = SqlCesCredential,
  @destination_type       = 'AzureEventHubsAmqp'

-- Add the tables to the stream group
EXEC sys.sp_add_object_to_event_stream_group
  @stream_group_name = 'SqlCesGroup',
  @object_name = 'dbo.Customer',
  @include_old_values = 0,      -- do not include old values columns that have changed from updates or deletes
  @include_all_columns = 1      -- include all columns, even those that haven't changed from updates or deletes

EXEC sys.sp_add_object_to_event_stream_group
  @stream_group_name = 'SqlCesGroup',
  @object_name = 'dbo.Product',
  @include_old_values = 1,      -- include old values for columns that have changed from updates or deletes
  @include_all_columns = 0      -- include only columns that have changed from updates or deletes

EXEC sys.sp_add_object_to_event_stream_group
  @stream_group_name = 'SqlCesGroup',
  @object_name = 'dbo.Order',
  @include_old_values = 1,      -- include old values for columns that have changed from updates or deletes
  @include_all_columns = 0      -- include only columns that have changed from updates or deletes

EXEC sys.sp_add_object_to_event_stream_group
  @stream_group_name = 'SqlCesGroup',
  @object_name = 'dbo.OrderDetail',
  @include_old_values = 1,      -- include old values for columns that have changed from updates or deletes
  @include_all_columns = 0      -- include only columns that have changed from updates or deletes

EXEC sys.sp_add_object_to_event_stream_group
  @stream_group_name = 'SqlCesGroup',
  @object_name = 'dbo.TableWithNoPK',
  @include_old_values = 0,      -- do not include old values columns that have changed from updates or deletes
  @include_all_columns = 0      -- include only columns that have changed from updates or deletes (with no PK, this is essentially useless)

-- Help views
EXEC sp_help_change_feed_table @source_schema = 'dbo', @source_name = 'Customer'
EXEC sp_help_change_feed_table @source_schema = 'dbo', @source_name = 'Product'
EXEC sp_help_change_feed_table @source_schema = 'dbo', @source_name = 'Order'
EXEC sp_help_change_feed_table @source_schema = 'dbo', @source_name = 'OrderDetail'
EXEC sp_help_change_feed_table @source_schema = 'dbo', @source_name = 'TableWithNoPK'

-- Check for errors
SELECT * FROM sys.dm_change_feed_errors ORDER BY entry_time
