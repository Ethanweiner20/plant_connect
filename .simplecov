if ENV['COVERAGE'] == 'true'
  SimpleCov.start do
    add_filter 'test'
  end
end
