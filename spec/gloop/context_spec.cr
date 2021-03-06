require "../spec_helper"

Spectator.describe Gloop::Context do
  subject { context }

  describe "#major_version" do
    specify { expect(&.major_version).to eq(4) }
  end

  describe "#minor_version" do
    specify { expect(&.minor_version).to eq(6) }
  end

  describe "#profile" do
    specify { expect(&.profile).to eq(Gloop::Context::Profile::Core) }
  end

  describe "#flags" do
    specify { expect(&.flags).to eq(Gloop::Context::Flags::Debug) }
  end

  describe "#vendor" do
    # Can't stub or expect a specific value, just expect it to work instead.
    specify { expect(&.vendor).to_not be_nil }
  end

  describe "#renderer" do
    # Can't stub or expect a specific value, just expect it to work instead.
    specify { expect(&.renderer).to_not be_nil }
  end

  describe "#version" do
    specify { expect(&.version).to start_with("4.6") }
  end

  describe "#shading_language_version" do
    specify { expect(&.shading_language_version).to start_with("4.6") }
  end
end
