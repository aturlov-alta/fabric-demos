-- Optional demo utility: shift dates by a fixed interval to simulate an update in the source
-- Purpose: trigger mirroring change feed by modifying date columns consistently

UPDATE SalesLT.SalesOrderHeader
SET OrderDate = DATEADD(MONTH, 3, OrderDate),
    DueDate = DATEADD(MONTH, 3, DueDate),
    ShipDate = CASE WHEN ShipDate IS NOT NULL THEN DATEADD(MONTH, 3, ShipDate) ELSE NULL END,
    ModifiedDate = SYSUTCDATETIME();

UPDATE SalesLT.SalesOrderDetail
SET ModifiedDate = SYSUTCDATETIME();
