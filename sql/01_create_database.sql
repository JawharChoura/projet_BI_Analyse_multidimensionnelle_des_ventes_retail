
:setvar DataPath "C:\DataAnalyticsProject\data"
:setvar DatabaseName "DataWarehouseRetail"


-- 01_create_database.sql
IF DB_ID('$(DatabaseName)') IS NULL
BEGIN
    EXEC('CREATE DATABASE [$(DatabaseName)]');
END
GO
USE [$(DatabaseName)];
GO

-- Schemas
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='stage') EXEC('CREATE SCHEMA stage');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='dw') EXEC('CREATE SCHEMA dw');
GO

-- Staging tables
IF OBJECT_ID('stage.Customers') IS NOT NULL DROP TABLE stage.Customers;
CREATE TABLE stage.Customers (
    CustomerID INT,
    CustomerName NVARCHAR(100),
    City NVARCHAR(100),
    Segment NVARCHAR(50)
);

IF OBJECT_ID('stage.Products') IS NOT NULL DROP TABLE stage.Products;
CREATE TABLE stage.Products (
    ProductID INT,
    ProductName NVARCHAR(100),
    Category NVARCHAR(100),
    Subcategory NVARCHAR(100),
    UnitPrice DECIMAL(10,2)
);

IF OBJECT_ID('stage.Stores') IS NOT NULL DROP TABLE stage.Stores;
CREATE TABLE stage.Stores (
    StoreID INT,
    StoreName NVARCHAR(100),
    City NVARCHAR(100),
    Region NVARCHAR(100)
);

IF OBJECT_ID('stage.Calendar') IS NOT NULL DROP TABLE stage.Calendar;
CREATE TABLE stage.Calendar (
    DateKey INT,
    FullDate DATE,
    Year INT,
    Quarter INT,
    MonthNumber INT,
    MonthName NVARCHAR(50),
    Day INT
);

IF OBJECT_ID('stage.Sales') IS NOT NULL DROP TABLE stage.Sales;
CREATE TABLE stage.Sales (
    SaleID INT,
    OrderDate DATE,
    CustomerID INT,
    ProductID INT,
    StoreID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);

-- DW tables
IF OBJECT_ID('dw.DimDate') IS NOT NULL DROP TABLE dw.DimDate;
CREATE TABLE dw.DimDate (
    DateKey INT NOT NULL PRIMARY KEY,
    FullDate DATE,
    [Year] INT,
    [Quarter] INT,
    MonthNumber INT,
    MonthName NVARCHAR(50),
    [Day] INT
);

IF OBJECT_ID('dw.DimCustomer') IS NOT NULL DROP TABLE dw.DimCustomer;
CREATE TABLE dw.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT UNIQUE,
    CustomerName NVARCHAR(100),
    City NVARCHAR(100),
    Segment NVARCHAR(50)
);

IF OBJECT_ID('dw.DimProduct') IS NOT NULL DROP TABLE dw.DimProduct;
CREATE TABLE dw.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT UNIQUE,
    ProductName NVARCHAR(100),
    Category NVARCHAR(100),
    Subcategory NVARCHAR(100)
);

IF OBJECT_ID('dw.DimStore') IS NOT NULL DROP TABLE dw.DimStore;
CREATE TABLE dw.DimStore (
    StoreKey INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT UNIQUE,
    StoreName NVARCHAR(100),
    City NVARCHAR(100),
    Region NVARCHAR(100)
);

IF OBJECT_ID('dw.FactSales') IS NOT NULL DROP TABLE dw.FactSales;
CREATE TABLE dw.FactSales (
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    StoreKey INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    SalesAmount AS (Quantity * UnitPrice) PERSISTED,
    CONSTRAINT FK_FactSales_DimDate FOREIGN KEY (DateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES dw.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactSales_DimProduct FOREIGN KEY (ProductKey) REFERENCES dw.DimProduct(ProductKey),
    CONSTRAINT FK_FactSales_DimStore FOREIGN KEY (StoreKey) REFERENCES dw.DimStore(StoreKey)
);

CREATE INDEX IX_FactSales_Date ON dw.FactSales(DateKey);
CREATE INDEX IX_FactSales_Product ON dw.FactSales(ProductKey);
CREATE INDEX IX_FactSales_Customer ON dw.FactSales(CustomerKey);
CREATE INDEX IX_FactSales_Store ON dw.FactSales(StoreKey);
