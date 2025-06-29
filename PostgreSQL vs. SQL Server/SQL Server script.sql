-- 1. Semicolon Terminator
-- Semicolon is optional
SELECT * FROM employees;

-- Required for CTE
WITH EmployeeCount AS (
    SELECT Role, COUNT(*) AS Count
    FROM employees
    GROUP BY Role
)
0SELECT * FROM EmployeeCount;

-- 2. Default Case Sensitivity
-- Case-insensitive
SELECT EmployeeID, Name FROM Employees;
SELECT employeeid, name FROM employees;

-- 3. Temporary Tables
CREATE TABLE #TempTable (
    EmployeeID INT,
    Name NVARCHAR(50)
);
INSERT INTO #TempTable VALUES (1, 'Alice');
SELECT * FROM #TempTable;

-- 4. String Concatenation
SELECT 'Hello, ' + Name AS Greeting FROM employees;

-- 5. Limiting Query Results
SELECT TOP 3 * FROM employees;

-- 6. Null Handling
SELECT ISNULL(Role, 'No Role') AS Role FROM employees;

-- 7. Auto-Incrementing IDs
CREATE TABLE employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY
);

-- 8. Boolean Data Type
CREATE TABLE employees (
    IsActive BIT
);
INSERT INTO employees (IsActive) VALUES (1);
SELECT IsActive FROM employees;

-- 9. Date and Time Functions
SELECT GETDATE() AS CurrentDate;

-- 10. Indexing
CREATE NONCLUSTERED INDEX idx_role ON employees (Role);

-- 11. Pagination
SELECT * FROM employees
ORDER BY EmployeeID
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;

-- 12. Comments
-- Single-line comment
/* Multi-line 
   comment */

-- 13. Default Values
CREATE TABLE employees (
    Role NVARCHAR(50) DEFAULT 'Employee'
);

-- 14. Transaction Management
BEGIN TRANSACTION;
INSERT INTO employees (Name, Role) VALUES ('Dave', 'Tester');
COMMIT;

-- 15. Data Types Differences
CREATE TABLE data_types (
    col1 UNIQUEIDENTIFIER,
    col2 NVARCHAR(MAX),
    col3 VARBINARY(MAX)
);

-- 16. Error Handling
BEGIN TRY
    SELECT 1 / 0 AS Result;
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;

-- 17. Views
CREATE VIEW active_employees AS
SELECT Name, Role
FROM employees
WHERE IsActive = 1;

-- 18. JSON Support
DECLARE @json NVARCHAR(MAX) = 
    N'[{"Name":"Alice","Role":"Developer"},{"Name":"Bob","Role":"Manager"}]';

SELECT Name, Role
FROM OPENJSON(@json)
WITH (
    Name NVARCHAR(50),
    Role NVARCHAR(50)
);
