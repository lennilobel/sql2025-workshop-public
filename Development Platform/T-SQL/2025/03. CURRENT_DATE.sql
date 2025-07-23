/* =================== CURRENT_DATE =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/functions/current-date-transact-sql?view=azuresqldb-current

USE MyDB
GO

-- CURRENT_DATE is a simple ANSI-compliant function that returns the current date in the format 'YYYY-MM-DD'.
SELECT CurrentDate = CURRENT_DATE

-- CURRENT_DATE is equivalent to:
SELECT CurrentDate = CAST(SYSDATETIME() AS date)

