# AdventureSales SQL scripts (for Fabric mirroring)

Use the following scripts to adjust the AdventureSales/AdventureWorks LT schema so it mirrors cleanly into Microsoft Fabric. These scripts focus on required compatibility changes only:

1. Required

- Convert bit UDT to tinyint for Fabric.sql
  Purpose: Converts specific bit-based user-defined type (UDT) columns to tinyint (0/1) so Fabric Mirroring can replicate them.

- Convert UDT to NVARCHAR for Fabric.sql
  Purpose: Removes NVARCHAR-based UDTs by converting them to equivalent NVARCHAR system types (preserves Unicode; avoids down-conversion to VARCHAR). Drops/recreates dependent constraints/views as needed.

2. Optional demo utilities

- Redistribute orders by dates.sql — spreads OrderDate/DueDate/ShipDate across a single year with realistic offsets; useful for demos.
- Update order dates.sql — shifts dates by a fixed interval to simulate an update in the source and trigger mirroring.

**Notes**

- Back up your database before applying structural changes.
- After running the two required scripts, configure Fabric Mirroring and proceed to Silver/Gold.
- See [FABRIC_SOLUTION.md](../FABRIC_SOLUTION.md) for the end-to-end context.
 - NVARCHAR support: Fabric Mirroring supports NVARCHAR (system types). UDTs are unsupported and must be removed. See Microsoft docs: https://learn.microsoft.com/en-us/fabric/mirroring/azure-sql-database-limitations#column-level
