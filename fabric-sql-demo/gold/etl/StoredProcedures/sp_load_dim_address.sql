create   procedure etl.sp_load_dim_address
as
begin
  set nocount on;

  begin try
    -- Initialize / read watermark
    exec etl.sp_init_watermark @object_name = 'dim.address';
    declare @hi datetime2(6) = (select high_watermark_utc from etl.watermark where object_name = 'dim.address');

    /* UPDATE existing naturals changed since watermark */
    update d
      set d.address_line1    = s.[AddressLine1],
          d.address_line2    = s.[AddressLine2],
          d.city             = s.[City],
          d.state_province   = s.[StateProvince],
          d.country_region   = s.[CountryRegion],
          d.postal_code      = s.[PostalCode],
          d.last_modified_at = s.[row_modified_at]
    from dim.address d
    join [SalesLakehouse].[silver].[mlv_addresses] s
      on s.[AddressID] = d.address_id
    where s.[row_modified_at] > @hi;

    /* INSERT new naturals with SK assignment */
    ;with src as (
      select s.*
      from [SalesLakehouse].[silver].[mlv_addresses] s
      where s.[row_modified_at] > @hi
    ),
    to_ins as (
      select s.*,
             row_number() over(order by s.[AddressID]) as rn
      from src s
      left join dim.address d on d.address_id = s.[AddressID]
      where d.address_id is null
    )
    insert into dim.address
    (
      address_sk, address_id, address_line1, address_line2, city,
      state_province, country_region, postal_code, last_modified_at
    )
    select
      rn + coalesce((select max(address_sk) from dim.address), 0),
      [AddressID], [AddressLine1], [AddressLine2], [City],
      [StateProvince], [CountryRegion], [PostalCode], [row_modified_at]
    from to_ins;

    /* Advance watermark explicitly (no DEFAULTs in table) */
    declare @new_hi datetime2(6) =
      (select coalesce(max([row_modified_at]), @hi)
       from [SalesLakehouse].[silver].[mlv_addresses]
       where [row_modified_at] > @hi);

    update etl.watermark
      set high_watermark_utc = @new_hi,
          last_updated_utc   = sysutcdatetime()
    where object_name = 'dim.address';
  end try

  begin catch
  -- Evaluate first (avoid inline function calls in EXEC)
    declare @errnum int    = null;
    declare @errsev int    = null;
    declare @errstate int  = null;
    declare @errmsg varchar(4000) = null;

  -- NOTE: If any ERROR_*() function still causes issues in your Fabric capacity,
  -- just comment them out and leave NULLs (fallback shown below).
    set @errnum   = error_number();
    set @errsev   = error_severity();
    set @errstate = error_state();
    set @errmsg   = convert(varchar(4000), error_message());

    exec etl.sp_log_error
       @proc_name      = 'etl.sp_load_dim_address',  -- <-- set proc name per loader
       @error_number   = @errnum,
       @error_severity = @errsev,
       @error_state    = @errstate,
       @error_message  = @errmsg;

    throw;
end catch

end;