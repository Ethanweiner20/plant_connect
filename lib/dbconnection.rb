class DBConnection
  def initialize(logger: nil)
    @db = PG.connect(dbname: 'bloomshare') # Configure for production
    @logger = logger
  end

  def query(sql, params)
    @logger.info("#{sql}: #{params}") if @logger
    @db.exec_params(sql, params)
  end

  def close_connection
    @db.finish
    @logger.info "Database connection closed."
  end
end