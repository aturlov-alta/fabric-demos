create   procedure etl.sp_load_dim_customer
as
begin
  set nocount on;
  declare @procname varchar(256) = 'etl.sp_load_dim_customer';

  begin try
    exec etl.sp_init_watermark @object_name = 'dim.customer';
    declare @hi datetime2(6) =
      (select high_watermark_utc from etl.watermark where object_name = 'dim.customer');

    /* UPDATE */
    update d
      set d.title            = s.[Title],
          d.first_name       = s.[FirstName],
          d.middle_name      = s.[MiddleName],
          d.last_name        = s.[LastName],
          d.full_name        = s.[full_name],
          d.company_name     = s.[CompanyName],
          d.email_address    = s.[EmailAddress],
          d.phone            = s.[Phone],
          d.last_modified_at = s.[row_modified_at]
    from dim.customer d
    join [SalesLakehouse].[silver].[mlv_customers] s
      on s.[CustomerID] = d.customer_id
    where s.[row_modified_at] > @hi;

    /* INSERT */
    declare @base_sk bigint = coalesce((select max(customer_sk) from dim.customer), 0);

    insert into dim.customer
    (
      customer_sk, customer_id, title, first_name, middle_name, last_name,
      full_name, company_name, email_address, phone, last_modified_at
    )
    select
      @base_sk + row_number() over(order by s.[CustomerID]),
      s.[CustomerID], s.[Title], s.[FirstName], s.[MiddleName], s.[LastName],
      s.[full_name], s.[CompanyName], s.[EmailAddress], s.[Phone], s.[row_modified_at]
    from [SalesLakehouse].[silver].[mlv_customers] s
    left join dim.customer d on d.customer_id = s.[CustomerID]
    where d.customer_id is null
      and s.[row_modified_at] > @hi;

    /* watermark */
    declare @new_hi datetime2(6) =
      (select coalesce(max([row_modified_at]), @hi)
       from [SalesLakehouse].[silver].[mlv_customers]
       where [row_modified_at] > @hi);

    update etl.watermark
      set high_watermark_utc = @new_hi,
          last_updated_utc   = sysutcdatetime()
    where object_name = 'dim.customer';
  end try
  begin catch
    declare @errnum int = null, @errsev int = null, @errstate int = null, @errmsg varchar(4000) = null;
    begin try
      set @errnum   = error_number();
      set @errsev   = error_severity();
      set @errstate = error_state();
      set @errmsg   = convert(varchar(4000), error_message());
    end try begin catch end catch;

    exec etl.sp_log_error
         @proc_name      = @procname,
         @error_number   = @errnum,
         @error_severity = @errsev,
         @error_state    = @errstate,
         @error_message  = @errmsg;

    throw;
  end catch
end;