--DimProduct

SELECT A.ProductSubcategoryID, A.Name AS PSC, B.Name AS PC
INTO StgProductCategory
FROM AdventureWorks2019.Production.ProductSubcategory AS A
JOIN AdventureWorks2019.Production.ProductCategory AS B
ON A.ProductCategoryID = B.ProductCategoryID

INSERT INTO DimProduct (ProductKey, ProductName, ProductCategory, ProductSubcategory, ListPrice)
SELECT P.ProductID, P.Name, SPC.PC, SPC.PSC, ListPrice
FROM AdventureWorks2019.Production.Product AS P
INNER JOIN StgProductCategory AS SPC
ON P.ProductSubcategoryID = SPC.ProductSubcategoryID

--DimDate

SELECT DISTINCT S.OrderDate
INTO StageOrderDate
FROM AdventureWorks2019.Sales.SalesOrderHeader AS S

SELECT DISTINCT S.DueDate
INTO StageDueDate
FROM AdventureWorks2019.Sales.SalesOrderHeader AS S

SELECT DISTINCT S.ShipDate
INTO StageShipDate
FROM AdventureWorks2019.Sales.SalesOrderHeader AS S

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

INSERT INTO dbo.DimCustomer(CustomerKey, FirstName, LastName, City, State, Country) 

SELECT DISTINCT CustomerStaging.CustomerKey, CustomerStaging.FirstName, CustomerStaging.LastName, 
CustomerStaging.City, CustomerStaging.StateProvince, CustomerStaging.Country
FROM 

( SELECT P.BusinessEntityID as CustomerKey, P.FirstName, P.LastName,
A.City, S.Name AS StateProvince, CR.Name AS Country, A.AddressID as aID,
ROW_NUMBER() over (partition by P.BusinessEntityID ORDER BY A.AddressID DESC) as RowNum
FROM
AdventureWorks2019.Person.Person as p  
JOIN AdventureWorks2019.Sales.Customer AS C ON P.BusinessEntityID = C.PersonID
INNER JOIN AdventureWorks2019.Person.BusinessEntity AS B ON P.BusinessEntityID = B.BusinessEntityID
INNER JOIN AdventureWorks2019.Person.BusinessEntityAddress AS BA ON B.BusinessEntityID = BA.BusinessEntityID
INNER JOIN AdventureWorks2019.Person.Address AS A ON BA.AddressID = A.AddressID
INNER JOIN AdventureWorks2019.Person.StateProvince AS S ON S.StateProvinceID = A.StateProvinceID
INNER JOIN AdventureWorks2019.Person.CountryRegion AS CR ON CR.CountryRegionCode = S.CountryRegionCode

) as CustomerStaging
WHERE CustomerStaging.RowNum = 1

--DimEmployee
INSERT INTO DimEmployee(EmployeeKey,FirstName,LastName,JobTitle, Department)
SELECT DISTINCT P.BusinessEntityID AS EmployeeKey, P.FirstName, P.LastName, E.JobTitle, D.Name AS Department
FROM AdventureWorks2019.Person.Person AS P
INNER JOIN AdventureWorks2019.HumanResources.Employee AS E ON P.BusinessEntityID = E.BusinessEntityID
INNER JOIN AdventureWorks2019.HumanResources.EmployeeDepartmentHistory AS EDH ON P.BusinessEntityID = EDH.BusinessEntityID
INNER JOIN AdventureWorks2019.HumanResources.Department AS D ON D.DepartmentID = EDH.DepartmentID
WHERE P.FirstName IS NOT NULL
  AND P.LastName IS NOT NULL 
  AND E.JobTitle IS NOT NULL
  AND D.Name = 'Sales'
  ORDER BY P.BusinessEntityID;
  
--FactSales
SELECT S.DateKey, S.FullDate
INTO StgFtOrderDate
FROM DimDate AS S

SELECT S.DateKey, S.FullDate
INTO StgFtDueDate
FROM DimDate AS S

SELECT S.DateKey, S.FullDate
INTO StgFtShipDate
FROM DimDate AS S

SELECT S.SalesOrderDetailID, S.ProductID, S.UnitPriceDiscount, S.UnitPrice*S.OrderQty AS SalesAmount, S.OrderQty, B.DueDate, B.ShipDate, B.OrderDate, B.CustomerID, B.SalesPersonID
INTO Stg_Sales
FROM Sales.SalesOrderDetail AS S
INNER JOIN Sales.SalesOrderHeader AS B
ON S.SalesOrderID = B.SalesOrderID

INSERT INTO Sales (SalesKey, OrderDateKey, DueDateKey,ShipDateKey,ProductKey, EmployeeKey, SalesQuantity,SalesAmount, DiscountAmount)
SELECT A.SalesOrderDetailID, C.DateKey,D.DateKey,E.DateKey, B.ProductKey, DE.EmployeeKey, A.OrderQty, A.SalesAmount, A.UnitPriceDiscount
FROM Stg_Sales AS A
INNER JOIN DimProduct AS B
ON A.ProductID = B.ProductKey
INNER JOIN StgFtOrderDate AS C
ON A.OrderDate = C.FullDate
INNER JOIN StgFtDueDate AS D
ON A.DueDate = D.FullDate
INNER JOIN StgFtShipDate AS E
ON A.ShipDate = E.FullDate
INNER JOIN DimEmployee AS DE
ON DE.EmployeeKey = A.SalesPersonID
