require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Aliasable" do

  # TODO: It would be better to tear these down and rebuild them before each
  # test, since some of the tests add or remove aliases.
  before :all do
    class Base
      extend Aliasable
      aka :base
    end

    class ChildA < Base
      aka :childA, :first_child
    end

    class ChildB < Base
      aka :childB
    end

  end

  describe ".aliases" do
    it "should return all known aliases" do
      Base.aliases.should eql({
        :base => Base,
        :childA => ChildA,
        :first_child => ChildA,
        :childB => ChildB
      })
    end
  end

  describe ".aka" do
    it "should allow an alias to be set" do
      lambda {
        class ChildC < Base
          aka :childC
        end
      }.should_not raise_error
    end
  end

  describe '.find' do
    it "should allow you to look up a class via its alias" do
      Base.find(:first_child).should equal ChildA
      Base.find(:childB).should equal ChildB
    end
  end

  it "should keep aliases of different class hierarchies separate" do
    class AnotherBase
      extend Aliasable
    end

    lambda {
      class AnotherChildA < AnotherBase
        aka :first_child
      end
    }.should_not raise_error

    AnotherBase.find(:first_child).should equal AnotherChildA
    Base.find(:first_child).should equal ChildA
  end

  it "shouldn't allow the same alias to be used more than once in the same hierarchy" do
    lambda {
      class BogusDuplicateChildA < Base
        aka :childA
      end
    }.should raise_error( ArgumentError, /already taken/ )
  end

  describe '.forget_aliases' do
    it "should forget all aliases" do
      Base.forget_aliases
      Base.aliases.should be_empty
    end
  end

end
