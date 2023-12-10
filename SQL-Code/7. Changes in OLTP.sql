-- Changes in OLTP
USE [Chinook]
GO



-- Display all records in the Customer table
--SELECT * FROM [dbo].[Customer]

-- Update the address of CustomerID 41
UPDATE [dbo].[Customer]
SET 
    [Address] = '456 Maple Street, Apt 207',
    [City] = 'Rivertown',
    [State] = 'CA',
    [PostalCode] = '90210',
    [Country] = 'United Kingdom'
WHERE [CustomerID] = 41;

-- Insert a new customer 'Grady Roberts'
INSERT INTO [Chinook].[dbo].[Customer]
(
    [CustomerID],
    [FirstName],
    [LastName],
    [Company],
    [Address],
    [City],
    [State],
    [Country],
    [PostalCode],
    [Phone],
    [Fax],
    [Email],
	[SupportRepId]
)
VALUES
(
    60,
    'Grady',
    'Roberts',
    'Red Om Films',
    '303 Park Ave S',
    'New York',
    'NY',
    'USA',
    'NY 10010',
    '+1 (212) 221-3546',
    '+1 (212) 221-4679',
    'redomfilms@aol.com',
	3
);

-- Insert new invoice and invoice line items of the customer 'Grady Roberts'
INSERT INTO [dbo].[Invoice]
(
    [InvoiceId],
    [CustomerId],
    [InvoiceDate],
    [BillingAddress],
    [BillingCity],
    [BillingState],
    [BillingCountry],
    [BillingPostalCode],
    [Total]
)
VALUES
(
    413,
    60,
    '2013-12-23', 
    '303 Park Ave S',
    'New York',
    'NY',
    'USA',
    'NY 10010',
    3.96
);

INSERT INTO [dbo].[InvoiceLine]
(
    [InvoiceLineId],
    [InvoiceId],
    [TrackId],
    [UnitPrice],
    [Quantity]
)
VALUES
(
    2241,
    413,
    3145,
    0.99,
    1
),
(
    2242,
    413,
    2645,
    0.99,
    1
),
(
    2243,
    413,
    1500,
    0.99,
    1
),
(
    2244,
    413,
    2,
    0.99,
    1
);
