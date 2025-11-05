create   procedure etl.sp_log_error
  @proc_name       varchar(256),
  @error_number    int            = null,
  @error_severity  int            = null,
  @error_state     int            = null,
  @error_message   varchar(4000)  = null
as
begin
  set nocount on;

  insert into etl.error_log
  (
    error_id, proc_name, error_time_utc,
    error_number, error_severity, error_state, error_line, error_message
  )
  values
  (
    abs(checksum(newid())),           -- generates a bigint ID
    @proc_name, sysutcdatetime(),     -- set timestamp explicitly (no DEFAULTs)
    @error_number, @error_severity, @error_state,
    null,                             -- error_line intentionally set to NULL
    @error_message
  );
end;