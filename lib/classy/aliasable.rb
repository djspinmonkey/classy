# Aliasable allows you to assign aliases to a class (probably symbols, but any
# unique objects would work) and look it up again later with that alias.  This
# alias-to-class hash is kept in a class variable, so each mapping is unique to
# a given class hierarchy.  Possible uses for this include friendlier DSLs or
# additional layers of dynamic abstraction when specifying classes.
#
# Note: As mentioned, this module keeps its identity map in a class variable,
# @@classy_aliases, on the extending class.  This could concievably lead to
# namespace conflicts and strange bugs in the unlikely event that this variable
# is used for anything else.  Later versions may implement a hash of identity
# maps as a class variable on the Aliasble module itself, but for reasons of
# complexity and performance, that has not been done at this time.
#
# Example:
#
#   class Parent
#     extend Aliasable
#     aka :pop
#   end
#   
#   class Child < Parent
#     aka :kid
#   end
#
#   Parent.find(:pop)   # => Parent
#   Parent.find(:kid)   # => Child
#
# More complex usage examples can be found in the aliasable_spec.rb file.
#
module Aliasable
  def self.extended (klass) #nodoc;
    klass.class_exec do
      class_variable_set(:@@classy_aliases, {})
    end
  end

  # When passed a class, just returns it.  When passed a symbol that is an
  # alias for a class, returns that class.
  #
  #   Testify::Framework::Base.find(:rspec)  # => Testify::Framework::RSpec
  #
  def find (klass)
    return klass if klass.kind_of? Class
    class_variable_get(:@@classy_aliases)[klass] or raise ArgumentError, "Could not find alias #{klass}"
  end

  # Forget all known aliases.
  #
  def forget_aliases
    class_variable_get(:@@classy_aliases).clear
  end

  # Specifies a symbol (or several) that a given framework might be known
  # by.  For example, if you wanted to refer to RSpec by :rspec or :spec,
  # you might do this:
  #
  #   class RSpec
  #     aka :rspec, spec
  #     ...
  #   end
  #
  def aka (*names)
    names.each do |name| 
      raise ArgumentError, "Called aka with an alias that is already taken." if class_variable_get(:@@classy_aliases).include? name
      class_variable_get(:@@classy_aliases)[name] = self
    end
  end

  # Return a hash of known aliases to Class objects
  #
  def aliases
    class_variable_get(:@@classy_aliases).dup
  end

end
