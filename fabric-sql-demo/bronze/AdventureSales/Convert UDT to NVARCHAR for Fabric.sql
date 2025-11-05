-- ============================================================================
-- CONVERT NVARCHAR-BASED UDT COLUMNS TO NVARCHAR (SYSTEM TYPES) FOR FABRIC
-- Removes User Defined Types (UDTs) based on NVARCHAR in the SalesLT schema
-- to make the schema compatible with Microsoft Fabric Database Mirroring.
-- Keeps NVARCHAR to preserve Unicode data (no down-conversion to VARCHAR).
-- ============================================================================
-- IMPORTANT: Backup your database before running this script!
-- ============================================================================

BEGIN TRANSACTION;

PRINT 'Starting conversion of NVARCHAR-based UDT columns to NVARCHAR system types...';
PRINT '';

-- ============================================================================
-- STEP 1: Drop dependent views with SCHEMABINDING (if present)
-- ============================================================================
PRINT 'Dropping dependent views with SCHEMABINDING (if they exist)...';

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vProductAndDescription' AND object_id = OBJECT_ID('SalesLT.vProductAndDescription'))
BEGIN
    DROP VIEW SalesLT.vProductAndDescription;
    PRINT '  - Dropped SalesLT.vProductAndDescription';
END

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vGetAllCategories' AND object_id = OBJECT_ID('SalesLT.vGetAllCategories'))
BEGIN
    DROP VIEW SalesLT.vGetAllCategories;
    PRINT '  - Dropped SalesLT.vGetAllCategories';
END

PRINT '';

-- ============================================================================
-- STEP 2: Drop dependent indexes and UNIQUE constraints likely to block ALTER COLUMN
-- ============================================================================
PRINT 'Dropping dependent indexes and constraints that may block ALTER COLUMN...';

-- Address table indexes
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Address_StateProvince' AND object_id = OBJECT_ID('SalesLT.Address'))
BEGIN
    DROP INDEX IX_Address_StateProvince ON SalesLT.Address;
    PRINT '  - Dropped IX_Address_StateProvince';
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Address_AddressLine1_AddressLine2_City_StateProvince_PostalCode_CountryRegion' AND object_id = OBJECT_ID('SalesLT.Address'))
BEGIN
    DROP INDEX IX_Address_AddressLine1_AddressLine2_City_StateProvince_PostalCode_CountryRegion ON SalesLT.Address;
    PRINT '  - Dropped IX_Address_AddressLine1_AddressLine2_City_StateProvince_PostalCode_CountryRegion';
END

-- Product table - UNIQUE constraint (not just an index)
IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'AK_Product_Name' AND parent_object_id = OBJECT_ID('SalesLT.Product'))
BEGIN
    ALTER TABLE SalesLT.Product DROP CONSTRAINT AK_Product_Name;
    PRINT '  - Dropped AK_Product_Name (UNIQUE constraint)';
END

-- ProductCategory table - UNIQUE constraint
IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'AK_ProductCategory_Name' AND parent_object_id = OBJECT_ID('SalesLT.ProductCategory'))
BEGIN
    ALTER TABLE SalesLT.ProductCategory DROP CONSTRAINT AK_ProductCategory_Name;
    PRINT '  - Dropped AK_ProductCategory_Name (UNIQUE constraint)';
END

-- ProductModel table - UNIQUE constraint
IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'AK_ProductModel_Name' AND parent_object_id = OBJECT_ID('SalesLT.ProductModel'))
BEGIN
    ALTER TABLE SalesLT.ProductModel DROP CONSTRAINT AK_ProductModel_Name;
    PRINT '  - Dropped AK_ProductModel_Name (UNIQUE constraint)';
END

PRINT '';

-- ============================================================================
-- STEP 3: Convert NVARCHAR-based UDT columns to equivalent NVARCHAR system types
-- ============================================================================
PRINT 'Converting UDT columns to NVARCHAR system types...';
PRINT '';

-- SalesLT.Customer
ALTER TABLE SalesLT.Customer ALTER COLUMN FirstName NVARCHAR(50) NOT NULL;
PRINT '  - Customer.FirstName: UDT -> NVARCHAR(50)';

ALTER TABLE SalesLT.Customer ALTER COLUMN MiddleName NVARCHAR(50) NULL;
PRINT '  - Customer.MiddleName: UDT -> NVARCHAR(50)';

ALTER TABLE SalesLT.Customer ALTER COLUMN LastName NVARCHAR(50) NOT NULL;
PRINT '  - Customer.LastName: UDT -> NVARCHAR(50)';

ALTER TABLE SalesLT.Customer ALTER COLUMN Phone NVARCHAR(25) NULL;
PRINT '  - Customer.Phone: UDT -> NVARCHAR(25)';

-- SalesLT.Address
ALTER TABLE SalesLT.Address ALTER COLUMN StateProvince NVARCHAR(50) NOT NULL;
PRINT '  - Address.StateProvince: UDT -> NVARCHAR(50)';

ALTER TABLE SalesLT.Address ALTER COLUMN CountryRegion NVARCHAR(50) NOT NULL;
PRINT '  - Address.CountryRegion: UDT -> NVARCHAR(50)';

-- SalesLT.CustomerAddress
ALTER TABLE SalesLT.CustomerAddress ALTER COLUMN AddressType NVARCHAR(50) NOT NULL;
PRINT '  - CustomerAddress.AddressType: UDT -> NVARCHAR(50)';

-- SalesLT.Product
ALTER TABLE SalesLT.Product ALTER COLUMN Name NVARCHAR(50) NOT NULL;
PRINT '  - Product.Name: UDT -> NVARCHAR(50)';

-- SalesLT.ProductCategory
ALTER TABLE SalesLT.ProductCategory ALTER COLUMN Name NVARCHAR(50) NOT NULL;
PRINT '  - ProductCategory.Name: UDT -> NVARCHAR(50)';

-- SalesLT.ProductModel
ALTER TABLE SalesLT.ProductModel ALTER COLUMN Name NVARCHAR(50) NOT NULL;
PRINT '  - ProductModel.Name: UDT -> NVARCHAR(50)';

-- SalesLT.SalesOrderHeader
ALTER TABLE SalesLT.SalesOrderHeader ALTER COLUMN AccountNumber NVARCHAR(15) NOT NULL;
PRINT '  - SalesOrderHeader.AccountNumber: UDT -> NVARCHAR(15)';

ALTER TABLE SalesLT.SalesOrderHeader ALTER COLUMN PurchaseOrderNumber NVARCHAR(25) NULL;
PRINT '  - SalesOrderHeader.PurchaseOrderNumber: UDT -> NVARCHAR(25)';

PRINT '';

-- ============================================================================
-- STEP 4: Recreate dropped indexes and UNIQUE constraints
-- ============================================================================
PRINT 'Recreating dropped indexes and UNIQUE constraints...';

-- Address table indexes
CREATE NONCLUSTERED INDEX IX_Address_StateProvince 
ON SalesLT.Address(StateProvince ASC);
PRINT '  - Recreated IX_Address_StateProvince';

CREATE NONCLUSTERED INDEX IX_Address_AddressLine1_AddressLine2_City_StateProvince_PostalCode_CountryRegion 
ON SalesLT.Address(StateProvince ASC, CountryRegion ASC);
PRINT '  - Recreated IX_Address_AddressLine1_AddressLine2_City_StateProvince_PostalCode_CountryRegion';

-- Product table - UNIQUE constraint
ALTER TABLE SalesLT.Product 
ADD CONSTRAINT AK_Product_Name UNIQUE NONCLUSTERED (Name ASC);
PRINT '  - Recreated AK_Product_Name (UNIQUE constraint)';

-- ProductCategory table - UNIQUE constraint
ALTER TABLE SalesLT.ProductCategory 
ADD CONSTRAINT AK_ProductCategory_Name UNIQUE NONCLUSTERED (Name ASC);
PRINT '  - Recreated AK_ProductCategory_Name (UNIQUE constraint)';

-- ProductModel table - UNIQUE constraint
ALTER TABLE SalesLT.ProductModel 
ADD CONSTRAINT AK_ProductModel_Name UNIQUE NONCLUSTERED (Name ASC);
PRINT '  - Recreated AK_ProductModel_Name (UNIQUE constraint)';

PRINT '';

-- ============================================================================
-- STEP 5: Recreate views with SCHEMABINDING
-- ============================================================================
PRINT 'Recreating dependent views with SCHEMABINDING...';

EXEC('
CREATE VIEW [SalesLT].[vProductAndDescription]
WITH SCHEMABINDING
AS
SELECT
    p.[ProductID]
    ,p.[Name]
    ,pm.[Name] AS [ProductModel]
    ,pmx.[Culture]
    ,pd.[Description]
FROM [SalesLT].[Product] p
    INNER JOIN [SalesLT].[ProductModel] pm
    ON p.[ProductModelID] = pm.[ProductModelID]
    INNER JOIN [SalesLT].[ProductModelProductDescription] pmx
    ON pm.[ProductModelID] = pmx.[ProductModelID]
    INNER JOIN [SalesLT].[ProductDescription] pd
    ON pmx.[ProductDescriptionID] = pd.[ProductDescriptionID];
');
PRINT '  - Recreated SalesLT.vProductAndDescription';

EXEC('
CREATE VIEW [SalesLT].[vGetAllCategories]
WITH SCHEMABINDING
AS
WITH CategoryCTE([ParentProductCategoryID], [ProductCategoryID], [Name]) AS
(
    SELECT [ParentProductCategoryID], [ProductCategoryID], [Name]
    FROM SalesLT.ProductCategory
    WHERE ParentProductCategoryID IS NULL

UNION ALL

    SELECT C.[ParentProductCategoryID], C.[ProductCategoryID], C.[Name]
    FROM SalesLT.ProductCategory AS C
    INNER JOIN CategoryCTE AS BC ON BC.ProductCategoryID = C.ParentProductCategoryID
)

SELECT PC.[Name] AS [ParentProductCategoryName], CCTE.[Name] as [ProductCategoryName], CCTE.[ProductCategoryID]
FROM CategoryCTE AS CCTE
JOIN SalesLT.ProductCategory AS PC
ON PC.[ProductCategoryID] = CCTE.[ParentProductCategoryID];
');
PRINT '  - Recreated SalesLT.vGetAllCategories';

PRINT '';

-- ============================================================================
-- STEP 6: Verification
-- ============================================================================
PRINT 'Verification: Checking for remaining NVARCHAR-based UDT columns...';
PRINT '';

SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS UserDefinedType,
    base_ty.name AS BaseType,
    CASE 
        WHEN base_ty.name = 'nvarchar' AND ty.is_user_defined = 1 THEN 'STILL UDT'
        ELSE 'Converted'
    END AS Status
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
JOIN sys.types base_ty ON ty.system_type_id = base_ty.user_type_id
WHERE s.name = 'SalesLT' 
  AND ty.is_user_defined = 1
  AND base_ty.name = 'nvarchar'
ORDER BY t.name, c.name;

PRINT '';
PRINT 'Review results and, if satisfied, COMMIT the transaction.';

-- COMMIT TRANSACTION;
-- To commit, uncomment the line above after verification.

-- To rollback if needed:
-- ROLLBACK TRANSACTION;

PRINT 'Transaction ready for commit (after verification).';
