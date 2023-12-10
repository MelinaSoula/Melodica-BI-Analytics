USE ChinookDW

-- Only for the first load
DELETE FROM FactSales;
DELETE FROM DimTrack;
DELETE FROM DimCustomer;
DELETE FROM DimPlaylist;



-- 1
INSERT INTO DimCustomer (CustomerID, CustomerName , CustomerCompany,
CustomerCity, CustomerState, CustomerCountry,
CustomerPostalCode, EmployeeName, EmployeeTitle)
  SELECT 
  [CustomerId],
  [FirstName]+ ' ' + [LastName],
  ISNULL([Company],'n/a'), 
  ISNULL([City],'n/a'), 
  ISNULL([State],'n/a'),
  ISNULL([Country],'n/a'),
  COALESCE(PostalCode,'n/a'),
  [EmployeeFirstName] + ' ' + [EmployeeLastName],
   ISNULL([EmployeeTitle],'n/a')
  FROM [ChinookStaging].[dbo].[Customers]


--2

INSERT INTO DimTrack (
TrackID, TrackName, AlbumName, ArtistName,  GenreName, TrackComposer, TrackMilliseconds)
  SELECT 
  [TrackId], 
  [Name],
  [AlbumTitle],
  ISNULL([ArtistName],'n/a'),
  ISNULL([GenreName],'n/a'),
  ISNULL([Composer],'n/a'),
  [Milliseconds]
  FROM [ChinookStaging].[dbo].[Tracks]

 
--3


 INSERT INTO DimPlaylist ([TrackID],[PlaylistID],[PlaylistName])
  SELECT 
  [TrackId], 
  [PlaylistId],
  ISNULL([Name],'n/a')
  FROM [ChinookStaging].[dbo].[Playlists]

  --4
 INSERT INTO  FactSales
 (TrackKey, CustomerKey, InvoiceDateKey,  InvoiceId, TrackPrice)
 SELECT  
		t.TrackKey,
        c.CustomerKey,
		CAST(FORMAT([InvoiceDate],'yyyyMMdd') AS INT),
		InvoiceId,
		[UnitPrice]
        FROM [ChinookStaging].[dbo].[Invoices] i
		INNER JOIN [ChinookDW].[dbo].DimCustomer c
		ON i.CustomerId = c.CustomerId
		INNER JOIN [ChinookDW].[dbo].DimTrack t
		ON t.TrackId = i.TrackId

select * from FactSales

