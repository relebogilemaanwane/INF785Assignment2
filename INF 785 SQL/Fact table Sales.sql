SELECT DISTINCT SOH.SalesOrderID AS SalesKey,OrderDate,DueDate,ShipDate,CustomerID,SalesPersonID,ProductID,OrderQty AS SalesQuantity,UnitPrice AS SalesAmount,UnitPriceDiscount AS DiscountAmount
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
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
  ORDER BY SOH.SalesOrderID;