CREATE TABLE [dim].[address] (

	[address_sk] bigint NOT NULL, 
	[address_id] int NOT NULL, 
	[address_line1] varchar(8000) NULL, 
	[address_line2] varchar(8000) NULL, 
	[city] varchar(8000) NULL, 
	[state_province] varchar(8000) NULL, 
	[country_region] varchar(8000) NULL, 
	[postal_code] varchar(8000) NULL, 
	[last_modified_at] datetime2(6) NULL
);