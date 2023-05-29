

INSERT INTO DimEmployee (EmployeeKey, FirstName, LastName, JobTitle, Department)
SELECT DISTINCT P.BusinessEntityID AS EmployeeKey, P.FirstName, P.LastName, E.JobTitle, D.Name AS Department
FROM AdventureWorks2019.Person.Person AS P
INNER JOIN [AdventureWorks2019].[HumanResources].[Employee] AS E ON P.[BusinessEntityID] = E.[BusinessEntityID]
INNER JOIN [AdventureWorks2019].[HumanResources].[EmployeeDepartmentHistory] AS EDH ON P.[BusinessEntityID] = EDH.[BusinessEntityID]
INNER JOIN [AdventureWorks2019].[HumanResources].[Department] AS D ON D.DepartmentID = EDH.[DepartmentID]
WHERE P.FirstName IS NOT NULL
  AND P.LastName IS NOT NULL 
  AND E.JobTitle IS NOT NULL
  AND D.Name IS NOT NULL
  AND P.PersonType = 'EM'

ORDER BY P.BusinessEntityID;