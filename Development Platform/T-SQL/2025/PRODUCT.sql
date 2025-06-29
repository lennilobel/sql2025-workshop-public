/* =================== PRODUCT =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/functions/product-aggregate-transact-sql?view=sql-server-ver17

CREATE TABLE OrderDetail (
    OrderId int,
    ProductId int,
    Price decimal(10, 4)
)

INSERT INTO OrderDetail (OrderId, ProductId, Price) VALUES
  (1, 101, 136.87),
  (1, 102, 29.57),
  (1, 103, 396.85),
  (2, 101, 136.87),
  (2, 102, 29.57),
  (3, 101, 136.87),
  (3, 102, 29.57),
  (4, 101, 149.22),
  (4, 102, 29.57)

-- Compute product of all prices and distinct prices for each ProductId
SELECT
    ProductId,
    ProductOfPrices = PRODUCT(Price),
    ProductOfDistinctPrices = PRODUCT(DISTINCT Price)
FROM
    OrderDetail
GROUP BY
    ProductId

SELECT
    OrderId,
    ProductId,
    Price,
    ProductOfPrices = PRODUCT(Price) OVER (PARTITION BY ProductId)
FROM
    OrderDetail

DROP TABLE OrderDetail
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
-- DEMO 1: GPT, generate a good description here

DECLARE @OrderDetail table (
    OrderId int,
    ProductId int,
    Price decimal(10, 4)
)

INSERT INTO @OrderDetail (OrderId, ProductId, Price) VALUES
  (1, 101, 136.87),
  (1, 102, 29.57),
  (1, 103, 396.85),
  (2, 101, 136.87),
  (2, 102, 29.57),
  (3, 101, 136.87),
  (3, 102, 29.57),
  (4, 101, 149.22),
  (4, 102, 29.57)

SELECT
    ProductId,
    ProductOfPrices = PRODUCT(Price),
    ProductOfDistinctPrices = PRODUCT(DISTINCT Price)
FROM
    @OrderDetail
GROUP BY
    ProductId

-- GPT, show an alternative way to compute the product of prices using OVER with PARTITION BY

GO


-- DEMO 2: GPT, generate a good description here

-- Financial instruments with periodic rates of return, including duplicate values
DECLARE @Instruments table (
    InstrumentId varchar(10),
    Period tinyint,
    RateOfReturn decimal(10, 4)
)

INSERT INTO @Instruments (InstrumentId, Period, RateOfReturn) VALUES
  ('BOND1', 1, 0.0350),
  ('BOND1', 2, 0.0275),
  ('BOND1', 3, 0.0350),    -- duplicate 3.5% return
  ('ETF1',  1, 0.0800),
  ('ETF1',  2, -0.0450),
  ('ETF1',  3, 0.0600),
  ('STOCK1', 1, 0.1250),
  ('STOCK1', 2, 0.0950),
  ('STOCK1', 3, 0.1250)    -- duplicate 12.5% return

-- Compute total and distinct compounded return
SELECT
    InstrumentId,
    CompoundedReturn = PRODUCT(1 + RateOfReturn),
    CompoundedDistinctReturn = PRODUCT(DISTINCT 1 + RateOfReturn)
FROM
    @Instruments
GROUP BY
    InstrumentId

-- GPT, show an alternative way to compute the product of prices using OVER with PARTITION BY
