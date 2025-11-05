CREATE TABLE [etl].[watermark] (

	[object_name] varchar(200) NOT NULL, 
	[high_watermark_utc] datetime2(6) NOT NULL, 
	[last_updated_utc] datetime2(6) NOT NULL
);