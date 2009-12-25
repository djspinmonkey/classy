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
# == Warning 
# This module defines an inherited() class method on the extending class to
# keep track of subclasses.  Unfortunately, if this method is later re-defined,
# this inherited() method is lost and subclass tracking will break.  In order
# to work around this, constructions like the following might be necessary:
#
#   class ChildC < Parent
#
#     class << self; alias :old_inherited :inherited end
#     def self.inherited(sub)
#       old_inherited(sub)
#       # ...your inherited() code...
#     end
#
#   end
#
# This is not considered an acceptable long-term state of affairs - hopefully
# in future versions of this module, this work around will not be necessary.
#
module SubclassAware

  def self.extended (klass) #:nodoc:
    klass.class_exec { class_variable_set(:@@subclasses, Set.new) }
  end

  # TODO: Find a way for self.inherited on the extended class not to blow
  # this away without requiring a bunch of alias chain hoops to be jumped
  # through.
  #
  def inherited(sub) #:nodoc:
    class_exec { class_variable_get(:@@subclasses).add sub }
  end

  # Return an array of all known subclasses (and sub-subclasses, etc) of this
  # class.
  #
  def subclasses
    class_exec { class_variable_get(:@@subclasses).to_a }
  end

  # Clear all info about known subclasses.  This method is probably mainly
  # useful for testing.
  #
  def forget_subclasses
    class_exec { class_variable_get(:@@subclasses).clear }
  end

end
