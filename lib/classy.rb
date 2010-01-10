path = File.join(File.dirname(__FILE__), 'classy')
Dir.foreach( path ) do |entry|
  require "#{path}/#{entry}" if entry =~ /\.rb$/
end
