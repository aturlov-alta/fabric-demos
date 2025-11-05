CREATE TABLE [etl].[error_log] (

	[error_id] bigint NOT NULL, 
	[proc_name] varchar(256) NULL, 
	[error_time_utc] datetime2(6) NOT NULL, 
	[error_number] int NULL, 
	[error_severity] int NULL, 
	[error_state] int NULL, 
	[error_line] int NULL, 
	[error_message] varchar(4000) NULL
);