require 'set'

# SubclassAware allows a class to know about all of the subclasses that descend
# from it in the inheritance tree.  
#
# == Example
#
#   class Parent
#     extend SubclassAware
#   end
#
#   class ChildA < Parent
#   end
#
#   class ChildB < Parent
#   end
#
#   Class ChildB1 < ChildB
#   end
#
#   Parent.subclasses   # => [ ChildA, ChildB, ChildB1 ]
#
# == Note
#
# SubclassAware sets and maintains the class variable @@classy_subclasses on
# the extending class, so in the unlikely event that this class variable is
# already in use, unusual bugs may result.
#
# == Warning 
#
# This module defines an inherited() class method.  If the extending class
# defines its own inherited() method without calling super, this inherited()
# method is lost and subclass tracking will break.  In order to work around
# this, make sure your inherited() method calls super.  Like this:
#
# class YourAwesomeClass
#   
#   def self.inherited
#     # ...your awesome logic
#     super  # <-- This is important.
#   end
#
# end
#
module SubclassAware

  # Instantiate a new Set of subclasses.  Not intended to be called directly.
  #
  def self.extended(klass)
    klass.class_exec { class_variable_set(:@@classy_subclasses, Set.new) }
  end

  # Add the inheriting class to the list of subclasses.  Not intended to be
  # called directly.
  #
  def inherited(sub)
    class_exec { class_variable_get(:@@classy_subclasses).add sub }
    super
  end

  # Return an array of all known subclasses (and sub-subclasses, etc) of this
  # class.
  #
  def subclasses
    class_exec { class_variable_get(:@@classy_subclasses).to_a }
  end

  # Clear all info about known subclasses.  This method is probably mainly
  # useful for testing.
  #
  def forget_subclasses
    class_exec { class_variable_get(:@@classy_subclasses).clear }
  end

end
