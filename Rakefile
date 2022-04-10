task default: :serve

task :serve do
  sh "bundle exec ruby app.rb"
end

task test: [:test_app, :test_search]

task :test_app do
  sh "bundle exec ruby test/test_app.rb"
end

task :test_search do
  sh "bundle exec ruby test/test_usda_plants_api.rb"
end
