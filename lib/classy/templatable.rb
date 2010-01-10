module Templatable

  # A hash to track templatable variables that have been locally set.
  # (Required to distinguish between variables explicitly set to nil and those
  # left as nil by default.)
  #
  @@ever_been_set = Hash.new { |hash, key| hash[key] = {} }

  def clear_templatable_attrs
  end

  def templatable_attr (*symbols)
    symbols.each do |symbol|
      # define the instance setter method
      #
      define_method("#{symbol}=".to_sym) do |value|
        instance_method_set("@#{symbol}", value)
        @@ever_been_set[self][symbol] = true
      end

      # define the instance getter method
      #
      define_method(symbol) do 
        if @@ever_been_set[self][symbol]
          return instance_method_get("@#{symbol}", value)
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

        # define the class getter method
        #
        self.class.send(:define_method, symbol) do
          class_variable_get("@@#{symbol}") if class_variable_defined?("@@#{symbol}")
        end
      end
    end
  end

end
