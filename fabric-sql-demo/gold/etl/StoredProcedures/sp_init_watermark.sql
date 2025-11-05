create   procedure etl.sp_init_watermark
  @object_name varchar(200),
  @initial_watermark_utc datetime2(6) = '1900-01-01T00:00:00.000'
as
begin
  set nocount on;

  if not exists (select 1 from etl.watermark where object_name = @object_name)
  begin
    insert into etl.watermark(object_name, high_watermark_utc, last_updated_utc)
    values (@object_name, @initial_watermark_utc, sysutcdatetime());
  end
end;