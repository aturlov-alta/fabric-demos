-- Optional demo utility: redistribute order dates to a realistic spread within a year
-- Purpose: seed the dataset with varied OrderDate/DueDate/ShipDate values and simulate source changes
-- Step 1: Create a temp table with random dates for 2008
IF OBJECT_ID('tempdb..#RandomDates') IS NOT NULL DROP TABLE #RandomDates;

CREATE TABLE #RandomDates (
    RowNum INT IDENTITY(1,1),
    NewOrderDate DATE
);

-- Insert 32 random dates in 2008
DECLARE @i INT = 1;
WHILE @i <= 32
BEGIN
    INSERT INTO #RandomDates (NewOrderDate)
    VALUES (DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2008-01-01'));
    SET @i += 1;
END

select * from #RandomDates;

-- Step 2: Create a temp table to map orders to random dates
IF OBJECT_ID('tempdb..#OrderMapping') IS NOT NULL DROP TABLE #OrderMapping;

SELECT 
    SalesOrderID,
    OrderDate,
    DueDate,
    ShipDate,
    ROW_NUMBER() OVER (ORDER BY SalesOrderID) as RowNum
INTO #OrderMapping
FROM SalesLT.SalesOrderHeader;

select * from #OrderMapping;

-- Step 3: Update orders using the random dates while preserving date offsets
UPDATE soh
SET 
    OrderDate = rd.NewOrderDate,
    DueDate = DATEADD(DAY, DATEDIFF(DAY, om.OrderDate, om.DueDate), rd.NewOrderDate),
    ShipDate = CASE 
                   WHEN om.ShipDate IS NOT NULL 
                   THEN DATEADD(DAY, DATEDIFF(DAY, om.OrderDate, om.ShipDate), rd.NewOrderDate)
                   ELSE NULL
               END
FROM SalesLT.SalesOrderHeader soh
INNER JOIN #OrderMapping om ON soh.SalesOrderID = om.SalesOrderID
INNER JOIN #RandomDates rd ON om.RowNum = rd.RowNum;

-- Verify the results
SELECT 
    SalesOrderID,
    OrderDate,
    DueDate,
    ShipDate,
    DATEDIFF(DAY, OrderDate, DueDate) as DaysToDue,
    DATEDIFF(DAY, OrderDate, ShipDate) as DaysToShip,
    ModifiedDate
FROM SalesLT.SalesOrderHeader
ORDER BY OrderDate;

select SalesOrderID, ModifiedDate from SalesLT.SalesOrderDetail;

-- Cleanup
DROP TABLE #RandomDates;
DROP TABLE #OrderMapping;

-- Alternative Simple Update: Shift all 2008 dates by 1 year

UPDATE SalesLT.SalesOrderHeader
SET OrderDate = DATEADD(YEAR, 1, OrderDate),
    DueDate = DATEADD(YEAR, 1, DueDate),
    ShipDate = DATEADD(YEAR, 1, ShipDate),
    ModifiedDate = SYSUTCDATETIME();
UPDATE SalesLT.SalesOrderDetail
SET ModifiedDate = SYSUTCDATETIME();
