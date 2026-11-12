
:setvar DataPath "C:\DataAnalyticsProject\data"
:setvar DatabaseName "DataWarehouseRetail"

USE DataWarehouseRetail;
GO	

TRUNCATE TABLE stage.Customers;
BULK INSERT stage.Customers
FROM 'C:\DataAnalyticsProject\data\Customers.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001');

TRUNCATE TABLE stage.Products;
BULK INSERT stage.Products
FROM 'C:\DataAnalyticsProject\data\Products.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001');

TRUNCATE TABLE stage.Stores;
BULK INSERT stage.Stores
FROM 'C:\DataAnalyticsProject\data\Stores.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001');

TRUNCATE TABLE stage.Calendar;
BULK INSERT stage.Calendar
FROM 'C:\DataAnalyticsProject\data\Calendar.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001');

TRUNCATE TABLE stage.Sales;
BULK INSERT stage.Sales
FROM 'C:\DataAnalyticsProject\data\Sales.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001');
