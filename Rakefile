task :console do
  def reload
    puts "Loading lambda.rb . . ."
    load './lambda.rb'
  end
  reload

  require 'irb'
  ARGV.shift
  IRB.start
end
