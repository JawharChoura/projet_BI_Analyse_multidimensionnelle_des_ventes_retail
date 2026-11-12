
:setvar DataPath "C:\DataAnalyticsProject\data"
:setvar DatabaseName "DataWarehouseRetail"

-- 03_transform_dw.sql
USE [$(DatabaseName)];
GO

-- Charger DimDate (SCD-0)
MERGE dw.DimDate AS tgt
USING (SELECT DateKey, FullDate, [Year], [Quarter], MonthNumber, MonthName, [Day] FROM stage.Calendar) AS src
ON (tgt.DateKey = src.DateKey)
WHEN NOT MATCHED THEN
    INSERT (DateKey, FullDate, [Year], [Quarter], MonthNumber, MonthName, [Day])
    VALUES (src.DateKey, src.FullDate, src.[Year], src.[Quarter], src.MonthNumber, src.MonthName, src.[Day]);

-- Charger DimCustomer (SCD-1)
MERGE dw.DimCustomer AS tgt
USING (SELECT CustomerID, CustomerName, City, Segment FROM stage.Customers) AS src
ON (tgt.CustomerID = src.CustomerID)
WHEN MATCHED AND (tgt.CustomerName <> src.CustomerName OR tgt.City <> src.City OR tgt.Segment <> src.Segment) THEN
    UPDATE SET CustomerName = src.CustomerName, City = src.City, Segment = src.Segment
WHEN NOT MATCHED THEN
    INSERT (CustomerID, CustomerName, City, Segment)
    VALUES (src.CustomerID, src.CustomerName, src.City, src.Segment);

-- Charger DimProduct (SCD-1)
MERGE dw.DimProduct AS tgt
USING (SELECT ProductID, ProductName, Category, Subcategory FROM stage.Products) AS src
ON (tgt.ProductID = src.ProductID)
WHEN MATCHED AND (tgt.ProductName <> src.ProductName OR tgt.Category <> src.Category OR tgt.Subcategory <> src.Subcategory) THEN
    UPDATE SET ProductName = src.ProductName, Category = src.Category, Subcategory = src.Subcategory
WHEN NOT MATCHED THEN
    INSERT (ProductID, ProductName, Category, Subcategory)
    VALUES (src.ProductID, src.ProductName, src.Category, src.Subcategory);

-- Charger DimStore (SCD-1)
MERGE dw.DimStore AS tgt
USING (SELECT StoreID, StoreName, City, Region FROM stage.Stores) AS src
ON (tgt.StoreID = src.StoreID)
WHEN MATCHED AND (tgt.StoreName <> src.StoreName OR tgt.City <> src.City OR tgt.Region <> src.Region) THEN
    UPDATE SET StoreName = src.StoreName, City = src.City, Region = src.Region
WHEN NOT MATCHED THEN
    INSERT (StoreID, StoreName, City, Region)
    VALUES (src.StoreID, src.StoreName, src.City, src.Region);

-- Charger FactSales
INSERT INTO dw.FactSales (DateKey, CustomerKey, ProductKey, StoreKey, Quantity, UnitPrice)
SELECT 
    CONVERT(INT, CONVERT(CHAR(8), s.OrderDate, 112)) AS DateKey,
    dc.CustomerKey,
    dp.ProductKey,
    ds.StoreKey,
    s.Quantity,
    s.UnitPrice
FROM stage.Sales s
JOIN dw.DimCustomer dc ON dc.CustomerID = s.CustomerID
JOIN dw.DimProduct dp ON dp.ProductID = s.ProductID
JOIN dw.DimStore ds ON ds.StoreID = s.StoreID
WHERE NOT EXISTS (
    SELECT 1 FROM dw.FactSales f
    WHERE f.DateKey = CONVERT(INT, CONVERT(CHAR(8), s.OrderDate, 112))
      AND f.CustomerKey = dc.CustomerKey
      AND f.ProductKey = dp.ProductKey
      AND f.StoreKey = ds.StoreKey
      AND f.Quantity = s.Quantity
      AND f.UnitPrice = s.UnitPrice
);
