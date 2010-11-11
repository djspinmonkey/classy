require File.join(File.dirname(__FILE__), 'spec_helper')

describe "SubclassAware" do

  before :all do
    # TODO: It would be nicer if this were torn down and re-built between each test.
    
    class ParentA
      extend SubclassAware

      # Make sure you call super in any self.inherited() methods!
      def self.inherited(sub)
        # ...your stuff...
        super  # <-- This is important
      end
    end

    class ParentB
      extend SubclassAware
    end

    class SubclassA1 < ParentA; end
    class SubclassA2 < ParentA; end
    class SubclassA3 < ParentA; end

    class SubclassB1 < ParentB; end
    class SubclassB2 < ParentB; end
    class SubclassB3 < ParentB; end
  end

  it "should keep track of all subclasses (and sub-sub, etc. classes) of a module which extends it" do
    ParentA::subclasses.should include(SubclassA1, SubclassA2, SubclassA3)
    ParentB::subclasses.should include(SubclassB1, SubclassB2, SubclassB3)
    ParentA::subclasses.should have(3).subclasses
    ParentB::subclasses.should have(3).subclasses
  end

  it "should not confuse the subclasses of two different extending classes" do
    ParentA.subclasses.should_not include(SubclassB1, SubclassB2, SubclassB3)
    ParentB.subclasses.should_not include(SubclassA1, SubclassA2, SubclassA3)
  end

  it "should forget all subclasses when forget_subclasses() is called" do
    ParentA.forget_subclasses
    ParentA.subclasses.should be_empty

    ParentB::subclasses.should include(SubclassB1, SubclassB2, SubclassB3)
    ParentB.subclasses.should have(3).subclasses
  end

end

