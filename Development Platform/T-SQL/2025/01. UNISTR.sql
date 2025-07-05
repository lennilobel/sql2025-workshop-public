/* =================== UNISTR (unicode strings) =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/functions/unistr-transact-sql?view=azuresqldb-current

CREATE DATABASE MyDB
GO

USE MyDB
GO

-- NCHAR requires clumsy concatenation
SELECT CONCAT('I ', NCHAR(0x2665), ' SQL Server 2025 ', NCHAR(0xD83D), NCHAR(0xDE03), '.')

-- UNISTR allows direct Unicode escape sequences with no concatentation required
SELECT UNISTR(N'I \2665 SQL Server 2025 \D83D\DE03.')   -- Version 1: Using UTF-16 surrogate pair; i.e., two 16-bit code units (high and low surrogate) that together form the Unicode character U+1F603
SELECT UNISTR(N'I \2665 SQL Server 2025 \+01F603.')     -- Version 2: Using full Unicode codepoint directly; i.e., SQL Server internally translates U+01F603 into the same surrogate pair \D83D\DE03.

-- UNISTR also allows you to define an alternate delimiter if you need to treat the backslash as a literal character
SELECT UNISTR(N'I $2665 SQL Server 2025 \ Azure SQL Database $D83D$DE03.', '$') -- Using $ as the delimiter, so backslashes are treated as literals
