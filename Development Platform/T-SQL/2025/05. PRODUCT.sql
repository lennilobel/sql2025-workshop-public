/* =================== PRODUCT =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/functions/product-aggregate-transact-sql?view=sql-server-ver17

USE MyDB
GO

CREATE TABLE OrderDetail (
    OrderId     int,
    ProductId   int,
    Price       decimal(10, 4)
)

INSERT INTO OrderDetail
  (OrderId, ProductId,  Price) VALUES
  (1,       101,        136.87),
  (1,       102,        29.57),
  (1,       103,        396.85),
  (2,       101,        136.87),
  (2,       102,        29.57),
  (3,       101,        136.87),
  (3,       102,        29.57),
  (4,       101,        149.22),
  (4,       102,        29.57)

-- Compute product of all prices and distinct prices for each ProductId
SELECT
    ProductId,
    ProductOfPrices = PRODUCT(Price),
    ProductOfDistinctPrices = PRODUCT(DISTINCT Price)
FROM
    OrderDetail
GROUP BY
    ProductId

-- Supports windowing with OVER
SELECT
    OrderId,
    ProductId,
    Price,
    ProductOfPrices = PRODUCT(Price) OVER (PARTITION BY ProductId)
FROM
    OrderDetail


-- Calculate compounded return from periodic rates

CREATE TABLE Instrument (
    InstrumentId    varchar(10),
    Period          tinyint,
    RateOfReturn    decimal(10, 4)
)

INSERT INTO Instrument
  (InstrumentId,    Period, RateOfReturn) VALUES
  ('BOND1',         1,      0.035),
  ('BOND1',         2,      0.0275),
  ('BOND1',         3,      0.0325),
  ('ETF1',          1,      0.08),
  ('ETF1',          2,      -0.045),
  ('ETF1',          3,      0.06),
  ('STOCK1',        1,      0.125),
  ('STOCK1',        2,      0.095),
  ('STOCK1',        3,      0.113)

-- Compute compounded return for each instrument
SELECT
  InstrumentId,
  CompoundedReturn = PRODUCT(1 + RateOfReturn) - 1,
  CompoundedReturnPercentage = FORMAT((PRODUCT(1 + RateOfReturn) - 1) * 100, 'N1') || '%'
FROM
  Instrument
GROUP BY
  InstrumentId

-- e.g., for BOND1
--   (1 + 0.035)  = 1.035   *       Period 1 return
--   (1 + 0.0275) = 1.0275  *       Period 2 return
--   (1 + 0.0325) = 1.0325  =       Period 3 return
--     1.098026 - 1 =               Growth factor (includes the original principal $1)
--     0.098026  =                  Compunded return (i.e., the percentage gain)
--     9.8%                         Isolated profit/loss percentage

-- Use windowing with `OVER` to calculate the compounded return for each individual row
SELECT
  InstrumentId,
  Period,
  RateOfReturn,
  CompoundedReturn = PRODUCT(1 + RateOfReturn) OVER (PARTITION BY InstrumentId) - 1,
  CompoundedReturnPercentage = FORMAT((PRODUCT(1 + RateOfReturn) OVER (PARTITION BY InstrumentId) - 1) * 100,'N1') || '%'
FROM
  Instrument
  
-- Cleanup
DROP TABLE IF EXISTS OrderDetail
DROP TABLE IF EXISTS Instrument
GO
