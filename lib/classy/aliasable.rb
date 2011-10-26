# Aliasable allows you to assign aliases to a class (usually symbols, but any
# unique objects would work) and look it up again later with that alias.  This
# alias-to-class hash is kept in a class variable, so each mapping is unique to
# a given class hierarchy.  Possible uses for this include friendlier DSLs or
# additional layers of dynamic abstraction when specifying classes.
#
# ==Example
#
#   class ParentClass
#     include Aliasable
#     aka :pop
#   end
#   
#   class AliasedSubclass < ParentClass
#     aka :kid
#   end
#
#   Parent.find(:pop)   # => ParentClass
#   Parent.find(:kid)   # => AliasedSubclass
#
# It is also possible to include Aliasable from a model, which will then track
# aliases of classes which include that module.
#
# == Example
#
#   module Meta
#     include Aliasable
#   end
#
#   class AliasedClass
#     include Meta
#
#     aka :klass
#   end
#
#   Meta.find(:klass)  # => AliasedClass
#
# More complex usage examples can be found in the aliasable_spec.rb file.
#
# NOTE: This defines a class variable, @@classy_aliases, on any class or module
# that includes Aliasable (or any class that includes a module including
# Aliasable).
#
# ANOTHER NOTE: As always, if you define your own .included methods, be sure to
# call super.
#
module Aliasable
  # Handle a module or class including Aliasable.
  #
  # :nodoc:
  #
  def self.included( mod )
    mod.extend ControllingClassMethods
    mod.extend UniversalClassMethods
    mod.extend AliasingClassMethods if mod.kind_of? Class       # If mod is a Class, the aliased classes get the class methods via inheritance.
    mod.send :class_variable_set, :@@classy_aliases, Hash.new
    super
  end

  # Methods for the class or module that the aliased classes inherit from or
  # extend.
  #
  module ControllingClassMethods
    # Handle a class including a module that has included Aliasable.
    #
    # :nodoc:
    #
    def included( klass )
      klass.extend AliasingClassMethods
      klass.extend UniversalClassMethods

      # Hoo boy.  We need to set the @@classy_aliases class variable in the
      # including class to point to the same actual hash object that the
      # @@classy_aliases variable on the controlling module points to.  When
      # everything is class based, this is done automatically, since
      # sub-classes share class variables.
      #
      klass.send(:class_variable_set, :@@classy_aliases, self.send(:class_variable_get, :@@classy_aliases))

      super
    end

    # When passed a class, just returns it.  When passed a symbol that is an
    # alias for a class, returns that class.
    #
    #   ParentClass.find(AliasedSubclass)   # => AliasedSubclass
    #   ParentClass.find(:kid)              # => AliasedSubclass
    #
    def find( nick )
      return nick if nick.kind_of? Class
      aliases[nick]
    end

    # Forget all known aliases.  Mainly useful for testing purposes.
    #
    def forget_aliases
      aliases.clear
    end

  end

  # Methods for the classes that get aliased.
  #
  module AliasingClassMethods
    # Specifies a symbol (or several) that a given framework might be known
    # by.  
    #
    #   class AnotherClass
    #     aka :kid2, :chunky_bacon
    #     ...
    #   end
    #
    def aka( *nicks )
      nicks.each do |nick| 
        raise ArgumentError, "Called aka with an alias that is already taken." if aliases.include? nick
        aliases[nick] = self
      end
    end
  end

  # Methods for both the controlling class/module and the aliased classes.
  #
  module UniversalClassMethods
    # Return a hash of known aliases to Class objects.
    #
    # DANGER DANGER: This is the actual hash used internally by Aliasable, not a
    # dup. If you mess with it, you might asplode things.
    #
    #   ParentClass.aliases                     # => { :pop => ParentClass, :kid => AliasedSubclass, :kid2 => AnotherClass, :chunky_bacon => AnotherClass }
    #   ParentClass.aliases[:thing] = "BOOM"    # This will end in tears.
    #
    def aliases
      send :class_variable_get, :@@classy_aliases
    end
  end
end
