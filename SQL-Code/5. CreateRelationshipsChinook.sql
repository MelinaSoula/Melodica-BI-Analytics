ALTER TABLE FactSales
ADD CONSTRAINT [FactSalesDimDateOrder] FOREIGN KEY (InvoiceDateKey)
REFERENCES DimDate (DateKey);

ALTER TABLE FactSales
ADD CONSTRAINT [FactSalesDimCustomer] FOREIGN KEY (CustomerKey)
REFERENCES DimCustomer (CustomerKey);

ALTER TABLE FactSales
ADD CONSTRAINT [FactSalesDimTrack] FOREIGN KEY (TrackKey)
REFERENCES DimTrack (TrackKey);

