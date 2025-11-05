CREATE TABLE [fact].[sales] (

	[sales_sk] bigint NOT NULL, 
	[sales_order_id] int NOT NULL, 
	[sales_order_detail_id] int NOT NULL, 
	[order_date_sk] int NOT NULL, 
	[customer_sk] bigint NOT NULL, 
	[product_sk] bigint NOT NULL, 
	[ship_to_address_sk] bigint NULL, 
	[bill_to_address_sk] bigint NULL, 
	[order_qty] int NULL, 
	[unit_price] decimal(19,4) NULL, 
	[unit_price_discount] decimal(19,4) NULL, 
	[unit_price_net] decimal(19,4) NULL, 
	[line_amount] decimal(19,4) NULL, 
	[sub_total] decimal(19,4) NULL, 
	[tax_amt] decimal(19,4) NULL, 
	[freight] decimal(19,4) NULL, 
	[total_due] decimal(21,4) NULL, 
	[last_modified_at] datetime2(6) NULL
);