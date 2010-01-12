# Templatable allows a class to set default variables for its instances.
#
# == Example
#
#   class Widget
#     extend Templatable
#
#     templatable_attr :awesomeness, :temperature
#     awesomeness :total
#   end
#
#   Widget.awesomeness    # => :total
#   Widget.temperature    # => nil
#
#   doodad = Widget.new
#   doodad.awesomeness    # => :total
#   doodad.temperature    # => nil
#
#   # New defaults affect existing instances.
#   Widget.temperature = :cool
#   Widget.temperature    # => :cool
#   doodad.temperature    # => :cool
#
#   # Instances can override the defaults.
#   doodad.awesomeness = nil
#   doodad.temperature = :cool
#   doodad.awesomeness    # => nil
#   doodad.temperature    # => :cool
#
# == Note
#
# The default values are stored as class variables of the same name as the
# associated instance variables.  This may lead to some surprising results, eg,
# if you set a default value on a subclass.
#
module Templatable

  # A hash to track templatable variables that have been locally set.
  # (Required to distinguish between variables explicitly set to nil and those
  # left as nil by default.)
  #
  # @private
  # :nodoc:
  #
  @@ever_been_set = Hash.new { |hash, key| hash[key] = {} }

  # Defines one or more templatable attrs, which will add instance methods
  # similar to Ruby's standard attr_accessor method, and will also add class
  # methods to set or get default values, as described above.
  #
  def templatable_attr (*symbols)
    symbols.each do |symbol|
      # define the instance setter method
      #
      define_method("#{symbol}=".to_sym) do |value|
        instance_variable_set("@#{symbol}", value)
        @@ever_been_set[self][symbol] = true
      end

      # define the instance getter method
      #
      define_method(symbol) do 
        if @@ever_been_set[self][symbol]
          return instance_variable_get("@#{symbol}")
        elsif self.class.class_variable_defined?("@@#{symbol}")
          return self.class.class_exec { class_variable_get("@@#{symbol}") }
        else
          return nil
        end
      end

      class_exec do
        # define the class setter method
        #
        # We have to use this send hack, since define_method is private.
        #
        self.class.send(:define_method, "#{symbol}=".to_sym) do |value|
          class_variable_set("@@#{symbol}", value)
        end

        # define the class getter/setter method
        #
        # We want to be able to call this like a dsl as a setter, or like a
        # class method as a getter, so we need variable arity, which
        # define_method doesn't support.  In order to use the standard `def`
        # with variable arity, eval'ing a string seems to be the only option.
        #
        # Oh man would I love for somebody to submit a patch to do this in a
        # less horrible way.
        #
        self.class.class_eval "
          def #{symbol} (value = nil)
            if value
              class_variable_set(\"@@#{symbol}\", value)
            end
            class_variable_get(\"@@#{symbol}\") if class_variable_defined?(\"@@#{symbol}\")
          end
        "
      end
    end
  end

end
