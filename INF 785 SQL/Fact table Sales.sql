SELECT DISTINCT SOD.SalesOrderDetailID AS SalesKey,OrderDate AS OrderDateKey,DueDate AS DueDateKey,ShipDate AS ShipDateKey, c.CustomerID AS CustomerKey,SalesPersonID AS SalesPersonKey,ProductID AS ProductKey,OrderQty AS SalesQuantity,UnitPrice AS SalesAmount,UnitPriceDiscount AS DiscountAmount
INTO stageSales
FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
INNER JOIN AdventureWorks2019.Sales.Customer as c ON soh.CustomerID = c.CustomerID
INNER JOIN AdventureWorks2019.Person.Person as p  ON P.BusinessEntityID = C.PersonID
WHERE SOH.SalesOrderID IS NOT NULL
  AND SOH.OrderDate IS NOT NULL 
  AND SOH.DueDate IS NOT NULL
  AND SOH.ShipDate IS NOT NULL
  AND SOH.CustomerID IS NOT NULL
  AND SOH.SalesPersonID IS NOT NULL
  AND SOD.ProductID IS NOT NULL
  AND SOD.OrderQty IS NOT NULL
  AND SOD.UnitPrice IS NOT NULL
  AND SOD.UnitPriceDiscount IS NOT NULL
  ORDER BY SOD.SalesOrderDetailID;


  SELECT DISTINCT d.DateKey as OrderDateKey, s.OrderDateKey as OrderDate INTO stageOrderDate FROM stageSales as s inner join DimDate as d on s.OrderDateKey = d.FullDate
  SELECT DISTINCT d.DateKey as DueDateKey, s.DueDateKey as DueDate  INTO stageDueDate FROM stageSales as s inner join DimDate as d on s.DueDateKey = d.FullDate
  SELECT DISTINCT d.DateKey as ShipDateKey, s.ShipDateKey as ShipDate INTO stageShipDate  FROM stageSales as s inner join DimDate as d on s.ShipDateKey = d.FullDate



  INSERT INTO Sales (SalesKey, OrderDateKey, DueDateKey, ShipDateKey, ProductKey, CustomerKey, EmployeeKey, SalesQuantity, SalesAmount, DiscountAmount)

  SELECT ss.SalesKey, sod.OrderDateKey, sdd.DueDateKey, ssd.ShipDateKey, ss.ProductKey, ss.CustomerKey, ss.SalesPersonKey, ss.SalesQuantity, (ss.SalesQuantity * ss.SalesAmount) as SalesAmount, ss.DiscountAmount 
  FROM stageSales as ss
  INNER JOIN stageOrderDate as sod ON sod.OrderDate = ss.OrderDateKey
  INNER JOIN stageDueDate as sdd ON sdd.DueDate = ss.DueDateKey
  INNER JOIN stageShipDate as ssd ON ssd.ShipDate = ss.ShipDateKey
  INNER JOIN DimEmployee as de ON de.EmployeeKey = ss.SalesPersonKey
  INNER JOIN DimProduct as dp ON dp.ProductKey = ss.ProductKey

