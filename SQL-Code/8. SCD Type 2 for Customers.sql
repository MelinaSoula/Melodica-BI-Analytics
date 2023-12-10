-- OLTP -> staging

-- Truncate staging table for Customers
USE [ChinookStaging]
GO
TRUNCATE TABLE [ChinookStaging].[dbo].[Customers];

-- Populate staging table for Customers
INSERT INTO [ChinookStaging].[dbo].[Customers]
(
    CustomerId, FirstName, LastName, Company, City, State, Country, PostalCode,
    EmployeeFirstName, EmployeeLastName, EmployeeTitle
)
SELECT 
    c.CustomerId, c.FirstName, c.LastName, c.Company, c.City, c.State, c.Country, c.PostalCode,
    e.FirstName, e.LastName ,e.Title
FROM [Chinook].[dbo].[Customer] c
INNER JOIN [Chinook].[dbo].[Employee] e ON c.SupportRepId = e.EmployeeId;

-- Truncate staging table for Invoices
TRUNCATE TABLE [ChinookStaging].[dbo].[Invoices];

-- Populate staging table for Invoices
INSERT INTO [ChinookStaging].[dbo].[Invoices]
(
    [TrackId], [InvoiceId], [CustomerId], [InvoiceDate], [UnitPrice]
)
SELECT
    il.TrackId, i.InvoiceId, i.CustomerId, i.InvoiceDate, il.UnitPrice
FROM [Chinook].[dbo].[Invoice] i
INNER JOIN [Chinook].[dbo].[InvoiceLine] il ON i.InvoiceId = il.InvoiceId
WHERE InvoiceDate >= '2013-12-23';

-- Staging -> DW

-- Drop and create staging table for DimCustomer
DROP TABLE IF EXISTS [ChinookStaging].[dbo].Staging_DimCustomer;
CREATE TABLE [ChinookStaging].[dbo].Staging_DimCustomer (
    CustomerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(70) NOT NULL,
    CustomerCompany VARCHAR(80) DEFAULT '' NOT NULL,
    CustomerCity VARCHAR(40) NOT NULL,
    CustomerState VARCHAR(40) DEFAULT '' NOT NULL,
    CustomerCountry VARCHAR(40) NOT NULL,
    CustomerPostalCode VARCHAR(10) NOT NULL,
    EmployeeName VARCHAR(50) NOT NULL,
    EmployeeTitle VARCHAR(30) NOT NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

-- Populate DimCustomer from staging
INSERT INTO Staging_DimCustomer  (CustomerID, CustomerName , CustomerCompany,
CustomerCity, CustomerState, CustomerCountry,
CustomerPostalCode, EmployeeName, EmployeeTitle)
SELECT 
    [CustomerId] AS customer_id,
    [FirstName]+ ' ' + [LastName] AS CustomerName,
    ISNULL([Company],'n/a') AS CustomerCompany, 
    ISNULL([City],'n/a') AS CustomerCity, 
    ISNULL([State],'n/a') AS CustomerState,
    ISNULL([Country],'n/a') AS CustomerCountry,
    COALESCE(PostalCode,'n/a') AS CustomerPostalCode,
    [EmployeeFirstName] + ' ' + [EmployeeLastName] AS EmployeeName,
    ISNULL([EmployeeTitle],'n/a') AS EmployeeTitle
FROM [ChinookStaging].[dbo].[Customers];

DECLARE @etldate DATE = '2013-12-23';

-- Drop the constraints

-- Perform the data synchronization
INSERT INTO [ChinookDW].[dbo].DimCustomer (
    CustomerID, CustomerName, CustomerCompany,
    CustomerCity, CustomerState, CustomerCountry,
    CustomerPostalCode, EmployeeName, EmployeeTitle,
    [RowStartDate], [RowChangeReason]
)
SELECT
    CustomerID, CustomerName, CustomerCompany,
    CustomerCity, CustomerState, CustomerCountry,
    CustomerPostalCode, EmployeeName, EmployeeTitle,
    @etldate, ActionName
FROM
(
    MERGE [ChinookDW].[dbo].DimCustomer AS target
    USING [ChinookStaging].[dbo].[Staging_DimCustomer] AS source
    ON target.[CustomerID] = source.[CustomerID]
    WHEN MATCHED AND source.CustomerCity <> target.CustomerCity AND target.[RowIsCurrent] = 1 THEN
        UPDATE SET
            target.RowIsCurrent = 0,
            target.RowEndDate = DATEADD(DAY, -1, @etldate),
            target.RowChangeReason = 'UPDATED NOT CURRENT'
    WHEN NOT MATCHED THEN
        INSERT (
            CustomerID, CustomerName, CustomerCompany,
            CustomerCity, CustomerState, CustomerCountry,
            CustomerPostalCode, EmployeeName, EmployeeTitle,
            [RowStartDate], [RowChangeReason]
        )
        VALUES (
            source.CustomerID, source.CustomerName, source.CustomerCompany,
            source.CustomerCity, source.CustomerState, source.CustomerCountry,
            source.CustomerPostalCode, source.EmployeeName, source.EmployeeTitle,
            CAST(@etldate AS DATE),
            'NEW RECORD'
        )
    WHEN NOT MATCHED BY SOURCE THEN
        UPDATE SET
            Target.RowEndDate = DATEADD(DAY, -1, @etldate),
            Target.RowIsCurrent = 0,
            Target.RowChangeReason = 'SOFT DELETE'
    OUTPUT
        source.CustomerID, source.CustomerName, source.CustomerCompany,
        source.CustomerCity, source.CustomerState, source.CustomerCountry,
        source.CustomerPostalCode, source.EmployeeName, source.EmployeeTitle,
        $Action AS ActionName
) AS Mrg
WHERE Mrg.ActionName = 'UPDATE'
    AND [CustomerID] IS NOT NULL;



-- Insert new facts into FactSales



INSERT INTO [ChinookDW].[dbo].FactSales 
(TrackKey, CustomerKey, InvoiceDateKey,  InvoiceId, TrackPrice)
SELECT
    t.TrackKey,
    c.CustomerKey,
    CAST(FORMAT([InvoiceDate],'yyyyMMdd') AS INT),
    InvoiceId,
    [UnitPrice]
FROM [ChinookStaging].[dbo].[Invoices] i
INNER JOIN [ChinookDW].[dbo].DimCustomer c ON i.CustomerId = c.CustomerId
INNER JOIN [ChinookDW].[dbo].DimTrack t ON t.TrackId = i.TrackId;



