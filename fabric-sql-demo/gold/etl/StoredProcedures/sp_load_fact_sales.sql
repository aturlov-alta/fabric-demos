create   procedure etl.sp_load_fact_sales
as
begin
  set nocount on;
  declare @procname varchar(256) = 'etl.sp_load_fact_sales';

  begin try
    exec etl.sp_init_watermark @object_name = 'fact.sales';
    declare @hi datetime2(6) =
      (select high_watermark_utc from etl.watermark where object_name = 'fact.sales');

    /* UPDATE existing facts from resolved source */
    update f
      set f.order_date_sk        = r.order_date_sk,
          f.customer_sk          = r.customer_sk,
          f.product_sk           = r.product_sk,
          f.ship_to_address_sk   = r.ship_to_address_sk,
          f.bill_to_address_sk   = r.bill_to_address_sk,
          f.order_qty            = r.order_qty,
          f.unit_price           = r.unit_price,
          f.unit_price_discount  = r.unit_price_discount,
          f.unit_price_net       = r.unit_price_net,
          f.line_amount          = r.line_amount,
          f.sub_total            = r.sub_total,
          f.tax_amt              = r.tax_amt,
          f.freight              = r.freight,
          f.total_due            = r.total_due,
          f.last_modified_at     = r.row_modified_at
    from fact.sales f
    join (
      select
        l.[SalesOrderID]        as sales_order_id,
        l.[SalesOrderDetailID]  as sales_order_detail_id,
        (year(l.[OrderDate])*10000 + month(l.[OrderDate])*100 + day(l.[OrderDate])) as order_date_sk,
        dp.product_sk,
        dc.customer_sk,
        da_ship.address_sk as ship_to_address_sk,
        da_bill.address_sk as bill_to_address_sk,
        cast(l.[OrderQty] as int) as order_qty,
        l.[UnitPrice]           as unit_price,
        l.[UnitPriceDiscount]   as unit_price_discount,
        l.[UnitPriceNet]        as unit_price_net,
        l.[LineAmount]          as line_amount,
        l.[SubTotal]            as sub_total,
        l.[TaxAmt]              as tax_amt,
        l.[Freight]             as freight,
        l.[TotalDue]            as total_due,
        l.[row_modified_at]     as row_modified_at
      from [SalesLakehouse].[silver].[mlv_saleslines] l
      left join dim.product  dp on dp.product_id  = l.[ProductID]
      left join dim.customer dc on dc.customer_id = l.[CustomerID]
      left join dim.address  da_ship on da_ship.address_id = l.[ShipToAddressID]
      left join dim.address  da_bill on da_bill.address_id = l.[BillToAddressID]
      where l.[row_modified_at] > @hi
    ) r
      on r.sales_order_id        = f.sales_order_id
     and r.sales_order_detail_id = f.sales_order_detail_id;

    /* INSERT new facts */
    declare @base_sk bigint = coalesce((select max(sales_sk) from fact.sales), 0);

    insert into fact.sales
    (
      sales_sk, sales_order_id, sales_order_detail_id,
      order_date_sk, customer_sk, product_sk,
      ship_to_address_sk, bill_to_address_sk,
      order_qty, unit_price, unit_price_discount, unit_price_net,
      line_amount, sub_total, tax_amt, freight, total_due, last_modified_at
    )
    select
      @base_sk + row_number() over(order by r.sales_order_id, r.sales_order_detail_id),
      r.sales_order_id, r.sales_order_detail_id,
      r.order_date_sk, r.customer_sk, r.product_sk,
      r.ship_to_address_sk, r.bill_to_address_sk,
      r.order_qty, r.unit_price, r.unit_price_discount, r.unit_price_net,
      r.line_amount, r.sub_total, r.tax_amt, r.freight, r.total_due, r.row_modified_at
    from (
      select
        l.[SalesOrderID]        as sales_order_id,
        l.[SalesOrderDetailID]  as sales_order_detail_id,
        (year(l.[OrderDate])*10000 + month(l.[OrderDate])*100 + day(l.[OrderDate])) as order_date_sk,
        dp.product_sk,
        dc.customer_sk,
        da_ship.address_sk as ship_to_address_sk,
        da_bill.address_sk as bill_to_address_sk,
        cast(l.[OrderQty] as int) as order_qty,
        l.[UnitPrice]           as unit_price,
        l.[UnitPriceDiscount]   as unit_price_discount,
        l.[UnitPriceNet]        as unit_price_net,
        l.[LineAmount]          as line_amount,
        l.[SubTotal]            as sub_total,
        l.[TaxAmt]              as tax_amt,
        l.[Freight]             as freight,
        l.[TotalDue]            as total_due,
        l.[row_modified_at]     as row_modified_at
      from [SalesLakehouse].[silver].[mlv_saleslines] l
      left join dim.product  dp on dp.product_id  = l.[ProductID]
      left join dim.customer dc on dc.customer_id = l.[CustomerID]
      left join dim.address  da_ship on da_ship.address_id = l.[ShipToAddressID]
      left join dim.address  da_bill on da_bill.address_id = l.[BillToAddressID]
      where l.[row_modified_at] > @hi
    ) r
    left join fact.sales f
      on f.sales_order_id        = r.sales_order_id
     and f.sales_order_detail_id = r.sales_order_detail_id
    where f.sales_order_id is null;

    /* watermark */
    declare @new_hi datetime2(6) =
      (select coalesce(max([row_modified_at]), @hi)
       from [SalesLakehouse].[silver].[mlv_saleslines]
       where [row_modified_at] > @hi);

    update etl.watermark
      set high_watermark_utc = @new_hi,
          last_updated_utc   = sysutcdatetime()
    where object_name = 'fact.sales';
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