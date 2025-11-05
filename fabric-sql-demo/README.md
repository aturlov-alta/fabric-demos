# SQL in Fabric — demo artifacts

This repository contains the demo artifacts used for the presentation "SQL in Fabric: Unified approach to data engineering, modelling and intelligence". It supplements the slides with SQL utilities and example notebooks designed specifically for Microsoft Fabric.

## Folders

- `bronze/` — Data preparation and cleansing scripts for the AdventureWorks/AdventureSales sample database.
- `gold/` — Contains a data warehouse Database project that includes dimension and fact tables and support tables and stored procedures. This Database project can be directly imported into Fabric and demonstrates how to build dimensional models and load facts/dimensions.
- `silver/` — Spark SQL Notebooks for creating and refreshing Materialized Lake Views (MLVs) in Fabric that represent silver layer dataset.

## What you'll find

- T-SQL scripts to prepare AdventureWorks LT data for mirroring into Fabric (data type conversions, date redistribution, utilities).
- ETL stored procedures and table definitions under `gold/etl` and `gold/fact`/`gold/dim` targeting a Fabric Warehouse.
- Two Jupyter notebooks in `silver/` showing how to create/refresh Materialized Lake Views in a Fabric Lakehouse.

## Microsoft Fabric only

This solution is intended for Microsoft Fabric and is not directly runnable locally. To use these artifacts, you’ll recreate the solution in your Fabric workspace following the high-level steps below. See `FABRIC_SOLUTION.md` for a guided overview.

## Architecture (medallion)

- Bronze: Source transactional data from AdventureSales LT in a SQL database. You'll need access to an Azure SQL database with the AdventureSales LT schema and data. Apply scripts in `bronze/AdventureSales` to make the schema and data compatible with Fabric mirroring. Then mirror the database into Fabric.
- Silver: Create a Fabric Lakehouse, add table shortcuts to the mirrored database tables, and create Materialized Lake Views (MLVs) with a schema fit for dimensional modeling using provided Notebooks.
- Gold: Create a Fabric Warehouse, deploy the dimensional model (DDL in `gold/dim` and `gold/fact`), and use stored procedures in `gold/etl` to load dimensions and facts.
- See [FABRIC_SOLUTION.md](FABRIC_SOLUTION.md) for the end-to-end context.

## Reproducing in Microsoft Fabric (high level)

1) Prepare the source database
	- Provision AdventureWorks LT (or AdventureSales LT) in Azure SQL.
	- Run the scripts in `bronze/AdventureSales` to adjust data types and dates for mirroring compatibility.

2) Mirror to Fabric
	- Configure a Mirrored Database in Fabric to mirror the prepared source.

3) Build silver (Lakehouse)
	- Create a Lakehouse and add shortcuts to the mirrored tables.
	- Use the `silver` notebooks (or your own SQL) to define and refresh MLVs that output the silver dataset. Provided Notebooks are in Jupyter format that is not directly compatible with Fabric, in which case create new Notebooks in Fabric workspace and copy content cell by cell.

4) Build gold (Warehouse)
	- Create a Warehouse in Fabric and run `gold/dim/dim.sql` and `gold/fact/fact.sql` to create schemas.
	- Deploy table DDL in `gold/dim/Tables` and `gold/fact/Tables`.
	- Run ETL stored procedures in `gold/etl/StoredProcedures` to populate dimensions and facts. Supporting tables: `gold/etl/Tables/watermark.sql` and `gold/etl/Tables/error_log.sql`.
	- Alternatively, import the entire Database project into Fabric as is.

## PDF slides

Download the presentation slides:

- [2025 SQL Saturday Toronto — Presentation PDF](2025_SQL_Saturday_Toronto_Alexander_Turlov.pdf)

## How to use this repository

These artifacts are demonstration material for Microsoft Fabric. Scripts are designed for use against a Fabric Mirrored Database (bronze), Fabric Lakehouse (silver), and Fabric Warehouse (gold). Notebooks are for demonstration only and are not directly compatible with Fabric nor can be run locally. Recreate Notebooks in Fabric manually using provided content.

# License

This repo inherits the top-level `LICENSE` file (GNU General Public License). If you prefer a more permissive license (MIT or Apache-2.0), say which one and I’ll update the project accordingly.

# Contributing

See `CONTRIBUTING.md` for contribution guidance and how to add the presentation PDF.

# Contact

Please use GitHub Issues for questions, bug reports, and feature requests. The maintainer monitors Issues as the single support channel.
