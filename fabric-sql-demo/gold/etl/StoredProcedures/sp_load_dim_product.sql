create   procedure etl.sp_load_dim_product
as
begin
  set nocount on;
  declare @procname varchar(256) = 'etl.sp_load_dim_product';

  begin try
    exec etl.sp_init_watermark @object_name = 'dim.product';
    declare @hi datetime2(6) =
      (select high_watermark_utc from etl.watermark where object_name = 'dim.product');

    /* UPDATE */
    update d
      set d.product_number      = s.[ProductNumber],
          d.product_name        = s.[ProductName],
          d.color               = s.[Color],
          d.size                = s.[Size],
          d.standard_cost       = s.[StandardCost],
          d.list_price          = s.[ListPrice],
          d.product_category_id = s.[ProductCategoryID],
          d.product_category    = s.[ProductCategory],
          d.product_model_id    = s.[ProductModelID],
          d.product_model       = s.[ProductModel],
          d.last_modified_at    = s.[row_modified_at]
    from dim.product d
    join [SalesLakehouse].[silver].[mlv_products] s
      on s.[ProductID] = d.product_id
    where s.[row_modified_at] > @hi;

    /* INSERT */
    declare @base_sk bigint = coalesce((select max(product_sk) from dim.product), 0);

    insert into dim.product
    (
      product_sk, product_id, product_number, product_name, color, size,
      standard_cost, list_price, product_category_id, product_category,
      product_model_id, product_model, last_modified_at
    )
    select
      @base_sk + row_number() over(order by s.[ProductID]),
      s.[ProductID], s.[ProductNumber], s.[ProductName], s.[Color], s.[Size],
      s.[StandardCost], s.[ListPrice], s.[ProductCategoryID], s.[ProductCategory],
      s.[ProductModelID], s.[ProductModel], s.[row_modified_at]
    from [SalesLakehouse].[silver].[mlv_products] s
    left join dim.product d on d.product_id = s.[ProductID]
    where d.product_id is null
      and s.[row_modified_at] > @hi;

    /* watermark */
    declare @new_hi datetime2(6) =
      (select coalesce(max([row_modified_at]), @hi)
       from [SalesLakehouse].[silver].[mlv_products]
       where [row_modified_at] > @hi);

    update etl.watermark
      set high_watermark_utc = @new_hi,
          last_updated_utc   = sysutcdatetime()
    where object_name = 'dim.product';
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