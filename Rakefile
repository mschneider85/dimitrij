task default: [:console]

desc 'Open an irb session preloaded with the environment'
task :console do
  require 'pry'
  require_relative 'lib/environment'

  Pry.start
end
