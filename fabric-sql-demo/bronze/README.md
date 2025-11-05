# Bronze: data preparation (Fabric mirroring)

This folder contains scripts used to shape and prepare the AdventureSales LT sample database so it can be mirrored into Microsoft Fabric. The `AdventureSales` subfolder contains only the scripts required for Fabric mirroring (bit UDT → tinyint; NVARCHAR-based UDTs → NVARCHAR system types).

**Key files (AdventureSales)**

- `Convert bit UDT to tinyint for Fabric.sql` — Convert bit-based UDT columns to tinyint (0/1) for mirroring.
- `Convert UDT to NVARCHAR for Fabric.sql` — Replace NVARCHAR-based UDTs with NVARCHAR system types (preserves Unicode).
 - Optional demo utilities: `Redistribute orders by dates.sql`, `Update order dates.sql` — for generating realistic dates and simulating changes to trigger mirroring.

**Usage notes**

- Review each script before running. They are intended for demo/sample databases only.
- Back up your database before applying any structural changes.
- After applying these changes, configure a Fabric Mirrored Database against this source.
- See [FABRIC_SOLUTION.md](../FABRIC_SOLUTION.md) for the end-to-end steps.
