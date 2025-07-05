/* =================== ANSI String Concatenation =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/string-concatenation-pipes-transact-sql?view=azuresqldb-current&viewFallbackFrom=sql-server-ver17

DECLARE @UserId int = NULL

SELECT PlusWithNulls    = 'User ID ' + CONVERT(varchar(max), @UserId)   -- Requires type conversion from int, a single NULL results in NULL
SELECT ConcatWithNulls  = CONCAT('User ID ', @UserId)                   -- Automatically converts int to string, any NULL values are converted to empty strings
SELECT AnsiWithNulls    = 'User ID ' || @UserId                         -- Automatically converts int to string (like CONCAT), a single NULL results in NULL (like +)
GO

DECLARE @UserId int = 16

SELECT PlusWithNonNulls     = 'User ID ' + CONVERT(varchar(max), @UserId)    -- Requires type conversion from int, a single NULL results in NULL
SELECT ConcatWithNonNulls   = CONCAT('User ID ', @UserId)                    -- Automatically converts int to string, any NULL values are converted to empty strings
SELECT AnsiWithNonNulls     = 'User ID ' || @UserId                          -- Automatically converts int to string (like CONCAT), a single NULL results in NULL (like +)
GO
