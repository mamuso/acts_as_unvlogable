require 'bundler'
Bundler::GemHelper.install_tasks

desc "Run tests"
task :spec do
	require 'rspec/core/rake_task'
	RSpec::Core::RakeTask.new(:spec)
end