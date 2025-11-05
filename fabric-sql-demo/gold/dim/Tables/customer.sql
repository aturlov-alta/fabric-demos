CREATE TABLE [dim].[customer] (

	[customer_sk] bigint NOT NULL, 
	[customer_id] int NOT NULL, 
	[title] varchar(8000) NULL, 
	[first_name] varchar(8000) NULL, 
	[middle_name] varchar(8000) NULL, 
	[last_name] varchar(8000) NULL, 
	[full_name] varchar(8000) NULL, 
	[company_name] varchar(8000) NULL, 
	[email_address] varchar(8000) NULL, 
	[phone] varchar(8000) NULL, 
	[last_modified_at] datetime2(6) NULL
);