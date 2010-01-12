require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Templatable" do

  before do
    destroy_class(Widget) if defined?(Widget)
    class Widget
      extend Templatable
      templatable_attr :temperature, :awesomeness
    end

    Widget.awesomeness = :total

    @doodad = Widget.new
  end

  it "should return the default value from the class when set" do
    Widget.awesomeness.should equal :total
  end

  it "should return nil from the class when unset" do
    Widget.temperature.should be_nil
  end

  it "should return the default value from an instance when set and not overridden" do
    @doodad.awesomeness.should equal :total
  end

  it "should return nil from an instance when unset and not overrideen" do
    @doodad.temperature.should be_nil
  end

  it "should allow instances to override the default values" do
    @doodad.awesomeness = :sorta_i_guess
    @doodad.awesomeness.should equal :sorta_i_guess
  end

  it "shouldn't affect other instances when overriding a value" do
    @whatsit = Widget.new
    @whatsit.awesomeness = :locally

    @doodad.awesomeness.should equal(:total)
  end

  it "shouldn't affect other Templatable classes" do
    destroy_class(Pony) if defined?(Pony)
    class Pony
      extend Templatable
      templatable_attr :name, :awesomeness
    end
    sugar = Pony.new    # You get a pony!

    Pony.awesomeness.should be_nil
    sugar.awesomeness.should be_nil

    Pony.awesomeness = :omg
    Pony.awesomeness.should equal(:omg)
    sugar.awesomeness.should equal(:omg)

    sugar.awesomeness = :meh    # Apparently, you get a bad pony.
    sugar.awesomeness.should equal(:meh)
  end

end
