require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Templatable" do

  before do
    if defined?(Widget)
      Widget.clear_templatable_attrs
      destroy_class(Widget) 
    end

    class Widget
      extend Templatable
      templatable_attr :temperature, :awesomeness
    end
  end

  context "with no templatable values set" do

    it "should return nil from the class getter methods" do
      Widget.awesomeness.should be_nil
      Widget.temperature.should be_nil
    end

    it "should initialize new objects with nil values" do
      doodad = Widget.new
      doodad.temperature.should be_nil
      doodad.awesomeness.should be_nil
    end

  end

  context "with one templatable value set" do

    before do
      Widget.awesomeness = :total
    end

    it "should return the templated value from the class getter method" do
      Widget.awesomeness.should equal :total
    end

    it "should return nil from the unset class getter method" do
      Widget.temperature.should be_nil
    end

    it "should only initialize new objects with values for the templated variables" do
      doodad = Widget.new
      doodad.temperature.should be_nil
      doodad.awesomeness.should equal :total
    end

  end

  context "with all templatable values set" do
    
    before do
      Widget.awesomeness = :pretty_dang
      Widget.temperature = :cool
      @thingy = Widget.new
    end

    it "should initialize new objects with values for all templatable variables" do
      @thingy.awesomeness.should equal(:pretty_dang)
      @thingy.temperature.should equal(:cool)
    end

    it "should be overridable in the instance" do
      @thingy.awesomeness = :fairly
      @thingy.awesomeness.should equal(:fairly)
    end

  end

end
