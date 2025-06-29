-- 1. Semicolon Terminator
-- Semicolon is mandatory
SELECT * FROM employees;

-- Required for CTE
WITH employee_count AS (
    SELECT role, COUNT(*) AS count
    FROM employees
    GROUP BY role
)
SELECT * FROM employee_count;

-- 2. Default Case Sensitivity
-- Case-sensitive unless explicitly quoted
SELECT id, name FROM employees; -- Works
SELECT ID, NAME FROM employees; -- Error
SELECT "ID", "NAME" FROM employees; -- Works if columns are quoted when created

-- 3. Temporary Tables
CREATE TEMP TABLE temp_table (
    id INT,
    name VARCHAR(50)
);
INSERT INTO temp_table VALUES (1, 'Alice');
SELECT * FROM temp_table;

-- 4. String Concatenation
SELECT 'Hello, ' || name AS greeting FROM employees;

-- 5. Limiting Query Results
SELECT * FROM employees LIMIT 3;

-- 6. Null Handling
SELECT COALESCE(role, 'No Role') AS role FROM employees;

-- 7. Auto-Incrementing IDs
CREATE TABLE employees (
    id SERIAL PRIMARY KEY
);

-- 8. Boolean Data Type
CREATE TABLE employees (
    is_active BOOLEAN
);
INSERT INTO employees (is_active) VALUES (TRUE);
SELECT is_active FROM employees;

-- 9. Date and Time Functions
SELECT NOW() AS current_date;

-- 10. Indexing
CREATE INDEX idx_role ON employees (role);

-- 11. Pagination
SELECT * FROM employees
ORDER BY id
OFFSET 5 LIMIT 5;

-- 12. Comments
-- Single-line comment
/* Multi-line 
   comment */

-- 13. Default Values
CREATE TABLE employees (
    role VARCHAR(50) DEFAULT 'Employee'
);

-- 14. Transaction Management
BEGIN;
INSERT INTO employees (name, role) VALUES ('Dave', 'Tester');
COMMIT;

-- 15. Data Types Differences
CREATE TABLE data_types (
    col1 UUID,
    col2 TEXT,
    col3 BYTEA
);

-- 16. Error Handling
DO $$
BEGIN
    PERFORM 1 / 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error occurred.';
END;
$$;

-- 17. Views
CREATE VIEW active_employees AS
SELECT name, role
FROM employees
WHERE is_active = TRUE;

-- 18. JSON Support
CREATE TABLE employees_json (data JSONB);

INSERT INTO employees_json (data) VALUES
    ('{"name":"Alice","role":"Developer"}'),
    ('{"name":"Bob","role":"Manager"}');

SELECT data->>'name' AS name, data->>'role' AS role
FROM employees_json;
