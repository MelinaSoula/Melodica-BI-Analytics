
/*
USE Chinook
GO

DELETE FROM [dbo].[InvoiceLine] WHERE [InvoiceId] = 413;
DELETE FROM [dbo].[Invoice] WHERE [InvoiceId] = 413;
DELETE  FROM [dbo].[Customer] WHERE [CustomerID] = 60;

 */


--CREATE DATABASE ChinookStaging
GO

USE ChinookStaging
GO

DROP TABLE IF EXISTS ChinookStaging.dbo.Customers;
DROP TABLE IF EXISTS ChinookStaging.dbo.Tracks;
DROP TABLE IF EXISTS ChinookStaging.dbo.Invoices;
DROP TABLE IF EXISTS ChinookStaging.dbo.Playlists;


--1. get data FROM Customer:
--  CustomerId, FirstName,LastName, Company, Address, City,
--  State, Country, PostalCode, 
--   EmployeeLastName, EmployeeFirstName, EmployeeTitle

-- NOT used: CUSTOMER -->[Fax],[Email] 
--           EMPLOYEE -->[EmployeeId],[BirthDate],[HireDate],[Address],[City],[State],[Country],[PostalCode],[Phone],[Fax],[Email]
SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Company,
    c.City,
    c.State,
    c.Country,
    c.PostalCode,
    e.FirstName AS EmployeeFirstName,
    e.LastName AS EmployeeLastName,
    e.Title AS EmployeeTitle
INTO dbo.Customers
FROM [Chinook].[dbo].[Customer] c
INNER JOIN [Chinook].[dbo].[Employee] e ON c.SupportRepId = e.EmployeeId;


--2 get FROM Track:
--TrackId, Name, Composer,
--AlbumName, ArtistName, MediaTypeName
-- GenreName, PlaylistName
--[Milliseconds],[Bytes]
--           
SELECT
    t.TrackId,
    t.Name,
	a.Title AS AlbumTitle,
	ar.Name AS ArtistName,
	g.Name AS GenreName,
    t.Composer,
    t.Milliseconds
INTO dbo.Tracks
FROM [Chinook].[dbo].[Track] t
INNER JOIN [Chinook].[dbo].[Album] a ON t.AlbumId = a.AlbumId
INNER JOIN [Chinook].[dbo].[Artist] ar ON ar.ArtistId = a.ArtistId
INNER JOIN [Chinook].[dbo].[PlaylistTrack] pt ON pt.TrackId = t.TrackId
INNER JOIN [Chinook].[dbo].[Playlist] p ON p.PlaylistId = pt.PlaylistId
INNER JOIN [Chinook].[dbo].[Genre] g ON g.GenreId = t.GenreId;

--get FROM Playlist and PlaylistTrack: [PlaylistId] [TrackId][Name]

SELECT 
pt.TrackId,
pt.PlaylistId,
p.Name
INTO dbo.Playlists
FROM [Chinook].[dbo].[PlaylistTrack] pt
INNER JOIN [Chinook].[dbo].[Playlist] p
ON pt.PlaylistId = p.PlaylistId

--get FROM Invoice
--InvoiceId, CustomerId, TrackId,
--InvoiceDate, UnitPrice, InvoiceTotal

-- NOT used: Invoice-->[BillingAddress],[BillingCity],[BillingState],[BillingCountry],[BillingPostalCode]
--       InvoiceLine-->[Quantity]
SELECT
    il.TrackId,
    i.InvoiceId,
    i.CustomerId,
    i.InvoiceDate,
    il.UnitPrice
INTO dbo.Invoices 
FROM [Chinook].[dbo].[Invoice] i
INNER JOIN [Chinook].[dbo].[InvoiceLine] il
ON i.InvoiceId = il.InvoiceId;


--date dimension


SELECT MIN(InvoiceDate) AS minDate, MAX(InvoiceDate) AS maxDate FROM dbo.Invoices;

