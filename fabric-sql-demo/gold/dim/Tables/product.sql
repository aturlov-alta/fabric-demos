CREATE TABLE [dim].[product] (

	[product_sk] bigint NOT NULL, 
	[product_id] int NOT NULL, 
	[product_number] varchar(8000) NULL, 
	[product_name] varchar(8000) NULL, 
	[color] varchar(8000) NULL, 
	[size] varchar(8000) NULL, 
	[standard_cost] decimal(19,4) NULL, 
	[list_price] decimal(19,4) NULL, 
	[product_category_id] int NULL, 
	[product_category] varchar(8000) NULL, 
	[product_model_id] int NULL, 
	[product_model] varchar(8000) NULL, 
	[last_modified_at] datetime2(6) NULL
);