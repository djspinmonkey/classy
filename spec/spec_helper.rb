$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'classy'
require 'rspec'
require 'rspec/autorun'

RSpec.configure do |config|
end

# Doesn't work for anything inside a module (eg, if you try to remove
# Testify::Framework::RSpec this will totally blow up).
def destroy_class ( klass )
  klass = klass.name.to_s if klass.kind_of? Class
  Object.class_exec { remove_const klass } if Object.const_defined? klass
end
