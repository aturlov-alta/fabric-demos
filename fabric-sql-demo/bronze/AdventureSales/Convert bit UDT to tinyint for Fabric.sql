-- ============================================================================
-- CONVERT BIT UDT COLUMNS TO TINYINT FOR FABRIC MIRRORING
-- Converts User Defined Type (UDT) columns based on bit to tinyint
-- in SalesLT schema to make them compatible with Fabric Database Mirroring
-- ============================================================================
-- IMPORTANT: Backup your database before running this script!
-- ============================================================================
-- According to Fabric documentation, bit columns are not replicated
-- Converting to tinyint (0 or 1) maintains the same logical values
-- while being compatible with Fabric mirroring
-- ============================================================================

BEGIN TRANSACTION;

PRINT 'Starting conversion of bit UDT columns to tinyint...';
PRINT '';

-- ============================================================================
-- STEP 1: Convert bit UDT columns to tinyint
-- ============================================================================
PRINT 'Converting bit UDT columns to tinyint...';
PRINT '';

-- ============================================================================
-- Table: SalesLT.Customer
-- ============================================================================
PRINT 'Converting SalesLT.Customer bit UDT columns...';

-- NameStyle: NameStyle UDT (bit) -> tinyint
ALTER TABLE SalesLT.Customer
ALTER COLUMN NameStyle tinyint NOT NULL;
PRINT '  - NameStyle: NameStyle UDT (bit) -> tinyint';

PRINT '';

-- ============================================================================
-- Table: SalesLT.SalesOrderHeader
-- ============================================================================
PRINT 'Converting SalesLT.SalesOrderHeader bit UDT columns...';

-- OnlineOrderFlag: Flag UDT (bit) -> tinyint
ALTER TABLE SalesLT.SalesOrderHeader
ALTER COLUMN OnlineOrderFlag tinyint NOT NULL;
PRINT '  - OnlineOrderFlag: Flag UDT (bit) -> tinyint';

PRINT '';

-- ============================================================================
-- STEP 2: Verification
-- ============================================================================
PRINT 'Verification: Checking for remaining bit-based UDT columns...';
PRINT '';

SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS UserDefinedType,
    base_ty.name AS BaseType,
    CASE 
        WHEN base_ty.name = 'bit' AND ty.is_user_defined = 1 THEN 'STILL INCOMPATIBLE'
        ELSE 'Compatible'
    END AS FabricCompatibility
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
JOIN sys.types base_ty ON ty.system_type_id = base_ty.user_type_id
WHERE s.name = 'SalesLT' 
  AND ty.is_user_defined = 1
  AND base_ty.name = 'bit'
ORDER BY t.name, c.name;

PRINT '';
PRINT 'If verification shows 0 rows, all bit UDT conversions were successful!';
PRINT 'Review results and verify data integrity before committing.';

-- Verify data values are still 0 or 1
PRINT '';
PRINT 'Verifying data integrity (all values should be 0 or 1)...';
PRINT '';

SELECT 'Customer.NameStyle' AS ColumnCheck, NameStyle, COUNT(*) AS Row_Count
FROM SalesLT.Customer
GROUP BY NameStyle
ORDER BY NameStyle;

SELECT 'SalesOrderHeader.OnlineOrderFlag' AS ColumnCheck, OnlineOrderFlag, COUNT(*) AS Row_Count
FROM SalesLT.SalesOrderHeader
GROUP BY OnlineOrderFlag
ORDER BY OnlineOrderFlag;

PRINT '';
PRINT 'Review results above. All values should be 0 or 1.';
PRINT 'If verified, uncomment COMMIT TRANSACTION below.';

-- COMMIT TRANSACTION;
-- Uncomment the line above after reviewing the verification results

-- To rollback if needed:
-- ROLLBACK TRANSACTION;

PRINT '';
PRINT '============================================================================';
PRINT 'SUMMARY: 2 bit UDT columns converted to tinyint across 2 tables';
PRINT '============================================================================';
PRINT 'Tables affected:';
PRINT '  - SalesLT.Customer (NameStyle)';
PRINT '  - SalesLT.SalesOrderHeader (OnlineOrderFlag)';
PRINT '============================================================================';
PRINT 'NOTE: Computed columns cannot be converted and will not replicate to Fabric.';
PRINT 'Computed columns in SalesLT schema:';
PRINT '  - SalesOrderDetail.LineTotal (numeric)';
PRINT '  - SalesOrderHeader.SalesOrderNumber (nvarchar)';
PRINT '  - SalesOrderHeader.TotalDue (money)';
PRINT 'These can be recreated as regular columns or calculated views in Fabric.';
PRINT '============================================================================';
