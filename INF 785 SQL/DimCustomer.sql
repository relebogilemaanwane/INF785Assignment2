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