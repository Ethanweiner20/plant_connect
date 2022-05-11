require 'sinatra/base'

class DBConnection
  def initialize(logger: nil)
    @db = if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    elsif Sinatra::Base.test?
      PG.connect(dbname: 'bloomshare-test')
    else
      PG.connect(dbname: 'bloomshare')
    end

    @logger = logger
  end

  def query(sql, params)
    @logger.info("#{sql}: #{params}") if @logger
    @db.exec_params(sql, params)
  end

  def clear_tables
    @db.exec "DELETE FROM inventories_plants;"
    @db.exec "DELETE FROM inventories;"
    @db.exec "DELETE FROM users;"
  end

  def close_connection
    @db.finish
    @logger.info "Database connection closed."
  end
end