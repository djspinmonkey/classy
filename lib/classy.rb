Dir.foreach( File.join( File.dirname(__FILE__), 'classy' ) ) do |entry|
  require "classy/#{entry}" if entry =~ /\.rb$/
end
