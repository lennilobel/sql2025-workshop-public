/* AI: Vector Utility Functions - Setup */

-- Create a table to hold 4-dimensional vectors
CREATE TABLE VectorDemo (
    VectorDemoId int PRIMARY KEY,
    RawVector vector(4)
)

-- Populate the table with three raw 4-dimensional vectors (i.e., raw = none are normalized):
INSERT INTO VectorDemo VALUES
  (1, '[1.0, 2.0, 2.0, 1.0]'),
  (2, '[0.0, 3.0, 4.0, 0.0]'),
  (3, '[2.0, 2.0, 2.0, 2.0]')

-- View the raw vectors
SELECT * FROM VectorDemo
