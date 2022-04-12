ROOT = File.expand_path(__dir__)

task default: :serve

task :serve do
  sh "bundle exec ruby app.rb"
end

task 'test' do
  sh "bundle exec ruby test/test.rb"
end

task 'coverage' do
  ENV['COVERAGE'] = 'true'
  rm_rf "coverage/"
  task = Rake::Task['test']
  task.reenable
  task.invoke
  sh "open coverage/index.html"
end
