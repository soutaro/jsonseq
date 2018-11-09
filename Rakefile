require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => [:test, :typecheck]

task :typecheck do
  sh("steep", "check", "lib")
  sh("steep", "check", "-I", "sig", "-I", "test", "test")
end
