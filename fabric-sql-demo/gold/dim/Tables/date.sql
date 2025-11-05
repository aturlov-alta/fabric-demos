CREATE TABLE [dim].[date] (

	[date_sk] int NOT NULL, 
	[full_date] date NOT NULL, 
	[year] int NOT NULL, 
	[quarter] int NOT NULL, 
	[quarter_name] varchar(10) NOT NULL, 
	[month] int NOT NULL, 
	[month_name] varchar(20) NOT NULL, 
	[day_of_month] int NOT NULL, 
	[day_of_week] int NOT NULL, 
	[day_name] varchar(20) NOT NULL, 
	[is_weekend] bit NOT NULL
);