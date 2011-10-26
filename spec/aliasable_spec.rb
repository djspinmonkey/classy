require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Aliasable" do

  before :all do
    Base.forget_aliases if Object.const_defined? "Base"
    class Base
      include Aliasable
      aka :base
    end

    class ChildA < Base
      aka :childA, :first_child
    end

    class ChildB < Base
      aka :childB
    end

    Meta.forget_aliases if Object.const_defined? "Meta"
    module Meta
      include Aliasable
    end

    class IncluderA
      include Meta
      aka :incA
    end

    class IncluderB
      include Meta
      aka :incB
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

    it "should work on modules as well as classes" do
      Meta.aliases.should eql({
        :incA => IncluderA,
        :incB => IncluderB
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

    it "should work on modules as well as bases" do
      Meta.find(:incA).should equal IncluderA
    end
  end

  it "should keep aliases of different class hierarchies separate" do
    class AnotherBase
      include Aliasable
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
    it "should clear all aliases for this hierarchy" do
      Base.forget_aliases
      Base.aliases.should be_empty
    end

    it "should work for modules as well as classes" do
      Meta.forget_aliases
      Meta.aliases.should be_empty
    end
  end

end
