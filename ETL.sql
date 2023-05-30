--DimProduct

SELECT A.ProductSubcategoryID, A.Name AS PSC, B.Name AS PC
INTO StgProductCategory
FROM Production.ProductSubcategory AS A
JOIN Production.ProductCategory AS B
ON A.ProductCategoryID = B.ProductCategoryID

INSERT INTO DimProduct (ProductKey, ProductName, ProductCategory, ProductSubcategory, ListPrice)
SELECT P.ProductID, P.Name, SPC.PC, SPC.PSC, ListPrice
FROM Production.Product AS P
INNER JOIN StgProductCategory AS SPC
ON P.ProductSubcategoryID = SPC.ProductSubcategoryID

--DimDate

SELECT DISTINCT S.OrderDate
INTO StageOrderDate
FROM Sales.SalesOrderHeader AS S

SELECT DISTINCT S.DueDate
INTO StageDueDate
FROM Sales.SalesOrderHeader AS S

SELECT DISTINCT S.ShipDate
INTO StageShipDate
FROM Sales.SalesOrderHeader AS S

INSERT INTO DimDate (DateKey, FullDate, DayOfWeek, MonthName, QuarterName, Year)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), S.OrderDate, 112)) AS DateKey,
    S.OrderDate AS FullDate,
    DATENAME(WEEKDAY, S.OrderDate) AS DayOfWeek,
    DATENAME(MONTH, S.OrderDate) AS MonthName,
    CASE WHEN DATEPART(QUARTER, S.OrderDate) = 1 THEN 'Q1'
         WHEN DATEPART(QUARTER, S.OrderDate) = 2 THEN 'Q2'
         WHEN DATEPART(QUARTER, S.OrderDate) = 3 THEN 'Q3'
         ELSE 'Q4'
    END AS QuarterName,
    YEAR(S.OrderDate) AS Year
FROM
    StageOrderDate AS S
WHERE 
	NOT EXISTS (
        SELECT 1
        FROM DimDate d
        WHERE d.FullDate = S.OrderDate
    )
ORDER BY
	DateKey
  
INSERT INTO DimDate (DateKey, FullDate, DayOfWeek, MonthName, QuarterName, Year)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), S.DueDate, 112)) AS DateKey,
    S.DueDate AS FullDate,
    DATENAME(WEEKDAY, S.DueDate) AS DayOfWeek,
    DATENAME(MONTH, S.DueDate) AS MonthName,
    CASE WHEN DATEPART(QUARTER, S.DueDate) = 1 THEN 'Q1'
         WHEN DATEPART(QUARTER, S.DueDate) = 2 THEN 'Q2'
         WHEN DATEPART(QUARTER, S.DueDate) = 3 THEN 'Q3'
         ELSE 'Q4'
    END AS QuarterName,
    YEAR(S.DueDate) AS Year
FROM
    StageDueDate AS S
WHERE 
	NOT EXISTS (
        SELECT 1
        FROM DimDate d
        WHERE d.FullDate = S.DueDate
    )
ORDER BY
	DateKey

INSERT INTO DimDate (DateKey, FullDate, DayOfWeek, MonthName, QuarterName, Year)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), S.ShipDate, 112)) AS DateKey,
    S.ShipDate AS FullDate,
    DATENAME(WEEKDAY, S.ShipDate) AS DayOfWeek,
    DATENAME(MONTH, S.ShipDate) AS MonthName,
    CASE WHEN DATEPART(QUARTER, S.ShipDate) = 1 THEN 'Q1'
         WHEN DATEPART(QUARTER, S.ShipDate) = 2 THEN 'Q2'
         WHEN DATEPART(QUARTER, S.ShipDate) = 3 THEN 'Q3'
         ELSE 'Q4'
    END AS QuarterName,
    YEAR(S.ShipDate) AS Year
FROM
    StageShipDate AS S
WHERE 
	NOT EXISTS (
        SELECT 1
        FROM DimDate d
        WHERE d.FullDate = S.ShipDate
    )
ORDER BY
	DateKey
 
--DimCustomer
--DimEmployee
--FactSales
