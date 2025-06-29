/* =================== Generating JSON =================== */

USE AdventureWorks2022
GO

/*** FOR JSON AUTO ***/

-- Relational
SELECT
	Customer.CustomerID,
	Customer.AccountNumber,
	SalesOrder.SalesOrderID,
	SalesOrder.OrderDate
 FROM
	Sales.Customer AS Customer
	INNER JOIN Sales.SalesOrderHeader AS SalesOrder ON SalesOrder.CustomerID = Customer.CustomerID
 WHERE
	Customer.CustomerID BETWEEN 11001 AND 11003
 ORDER BY
	Customer.CustomerID

-- FOR JSON AUTO
SELECT
	Customer.CustomerID,
	Customer.AccountNumber,
	SalesOrder.SalesOrderID,
	SalesOrder.OrderDate
 FROM
	Sales.Customer AS Customer
	INNER JOIN Sales.SalesOrderHeader AS SalesOrder ON SalesOrder.CustomerID = Customer.CustomerID
 WHERE
	Customer.CustomerID BETWEEN 11001 AND 11003
 ORDER BY
	Customer.CustomerID
 FOR JSON AUTO

-- FOR JSON AUTO, ROOT
SELECT
	Customer.CustomerID,
	Customer.AccountNumber,
	SalesOrder.SalesOrderID,
	SalesOrder.OrderDate
 FROM
	Sales.Customer AS Customer
	INNER JOIN Sales.SalesOrderHeader AS SalesOrder ON SalesOrder.CustomerID = Customer.CustomerID
 WHERE
	Customer.CustomerID BETWEEN 11001 AND 11003
 ORDER BY
	Customer.CustomerID
 FOR JSON AUTO, ROOT

-- FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
SELECT
	Customer.CustomerID,
	Customer.AccountNumber,
	SalesOrder.SalesOrderID,
	SalesOrder.OrderDate
 FROM
	Sales.Customer AS Customer
	INNER JOIN Sales.SalesOrderHeader AS SalesOrder ON SalesOrder.CustomerID = Customer.CustomerID
 WHERE
	Customer.CustomerID = 11003
 ORDER BY
	Customer.CustomerID
 FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER


/*** Storing JSON to variable ***/

-- FOR JSON to an NVARCHAR variable
DECLARE @JsonData AS nvarchar(max)
SET @JsonData =
(
	SELECT
		Customer.CustomerID,
		Customer.AccountNumber,
		SalesOrder.SalesOrderID,
		SalesOrder.OrderDate
	 FROM
		Sales.Customer AS Customer
		INNER JOIN Sales.SalesOrderHeader AS SalesOrder ON SalesOrder.CustomerID = Customer.CustomerID
	 WHERE
		Customer.CustomerID BETWEEN 11001 AND 11003
	 ORDER BY
		Customer.CustomerID
	 FOR JSON AUTO
)
SELECT @JsonData
GO


/*** Nested FOR JSON queries ***/

-- FOR JSON nested in another SELECT
SELECT 
	CustomerID,
	AccountNumber,
	(SELECT SalesOrderID, TotalDue, OrderDate, ShipDate
	  FROM Sales.SalesOrderHeader AS SalesOrder
	  WHERE CustomerID = Customer.CustomerID 
	  FOR JSON AUTO) AS SalesOrders
 FROM
	Sales.Customer AS Customer
 WHERE
	Customer.CustomerID BETWEEN 11001 AND 11003
 ORDER BY
	Customer.CustomerID


/*** FOR JSON PATH ***/

-- FOR JSON PATH (simple example)
SELECT
	Customer.CustomerID,
	Customer.AccountNumber,
	SalesOrder.SalesOrderID,
	SalesOrder.OrderDate
 FROM
	Sales.Customer AS Customer
	INNER JOIN Sales.SalesOrderHeader AS SalesOrder ON SalesOrder.CustomerID = Customer.CustomerID
 WHERE
	Customer.CustomerID BETWEEN 11001 AND 11003
 ORDER BY
	Customer.CustomerID
 FOR JSON PATH

-- FOR JSON PATH (nested example)
SELECT 
	CustomerID,
	AccountNumber,
	Person.FirstName AS [CustomerName.First],
	Person.LastName AS [CustomerName.Last],
	(SELECT SalesOrderID,
			TotalDue,
			OrderDate, 
			ShipDate,
			(SELECT ProductID, 
					OrderQty, 
					LineTotal
			  FROM Sales.SalesOrderDetail
			  WHERE SalesOrderID = OrderHeader.SalesOrderID
			  FOR JSON PATH) AS OrderDetail
	  FROM Sales.SalesOrderHeader AS OrderHeader
	  WHERE CustomerID = Customer.CustomerID 
	  FOR JSON PATH) AS OrderHeader
 FROM
	Sales.Customer AS Customer
	INNER JOIN Person.Person ON Person.BusinessEntityID = Customer.PersonID
 WHERE
	CustomerID BETWEEN 11001 AND 11002
 FOR JSON PATH

-- Same using JSON AUTO with traditional JOINs doesn't let you control hierarchical nesting (always one perjoin)
SELECT 
	Customer.CustomerID,
	Customer.AccountNumber,
	Person.FirstName AS [CustomerName.First],
	Person.LastName AS [CustomerName.Last],
	OrderHeader.SalesOrderID,
	OrderHeader.TotalDue,
	OrderHeader.OrderDate, 
	OrderHeader.ShipDate,
	OrderDetail.ProductID, 
	OrderDetail.OrderQty, 
	OrderDetail.LineTotal
 FROM
	Sales.Customer AS Customer
	INNER JOIN Person.Person ON Person.BusinessEntityID = Customer.PersonID
    INNER JOIN Sales.SalesOrderHeader AS OrderHeader ON OrderHeader.CustomerID = Customer.CustomerID
	INNER JOIN Sales.SalesOrderDetail AS OrderDetail ON OrderDetail.SalesOrderID = OrderHeader.SalesOrderID
 WHERE
	Customer.CustomerID BETWEEN 11001 AND 11002
 FOR JSON AUTO
