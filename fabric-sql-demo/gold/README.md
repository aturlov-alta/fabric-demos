# Gold: ETL, dimensional model and artifacts (Fabric Warehouse)

This folder contains the SQL Databse project files, ETL scripts, stored procedures and table definitions used to build the dimensional model in the demo.
This Database project can be opened in VS Code using a Database Projects extension.
This Database project can be imported directly into Fabric as a Warehouse.

**Structure**

- `etl/` — ETL orchestration scripts and stored procedures. Look in `etl/StoredProcedures` for sample stored procs used to initialize watermarks and load dimensions and facts.
- `dim/` — Dimension table DDL and helper scripts. There's a `dim.sql` to create the schema and `Tables/` with individual dimension DDL files.
- `fact/` — Fact table DDL and `fact.sql` entry script.

**How to run (in Fabric)**

You can set up the Gold layer in two ways:

Option A — Direct import as a Warehouse

1. Import this Database project into your Fabric workspace as a Warehouse.
2. Validate that schemas, tables, and stored procedures are created.
3. Run the ETL stored procedures in `etl/StoredProcedures` to seed/update dimensions and load facts.

Option B — Manual creation and configuration

1. Create a new Warehouse in Fabric.
2. Run `dim/dim.sql` and `fact/fact.sql` to create the `dim` and `fact` schemas.
3. Deploy table DDL in `dim/Tables/` and `fact/Tables/` to create dimension and fact tables.
4. Create the supporting ETL tables in `etl/Tables/` (`watermark.sql` and `error_log.sql`).
5. Run ETL stored procedures in `etl/StoredProcedures` to populate dimensions and facts.

**Notes**

- The ETL scripts are designed for demos; they use simple watermarking and logging (see `etl/Tables/watermark.sql` and `etl/Tables/error_log.sql`).
- See [FABRIC_SOLUTION.md](../FABRIC_SOLUTION.md) for the end-to-end context.
