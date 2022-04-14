ROOT = File.expand_path(__dir__)

task default: :serve

desc 'Test on local development server'
task :serve do
  sh "bundle exec ruby app.rb"
end

desc 'Run tests'
task 'test' do
  sh "bundle exec ruby test/test.rb"
end

desc 'Run tests and view coverage results'
task 'coverage' do
  ENV['COVERAGE'] = 'true'
  rm_rf "coverage/"
  task = Rake::Task['test']
  task.reenable
  task.invoke
  sh "open coverage/index.html"
end

desc 'Deploy app to Heroku'
task 'deploy' do
  sh "git push heroku main"
end