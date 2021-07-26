require "../spec_helper"

Spectator.describe Gloop::Capability do
  subject(capability) { Gloop::Capability::Blend }

  describe "#enable" do
    it "enables a capability" do
      capability.enable
      is_expected.to be_enabled
    end
  end

  describe "#disable" do
    it "disables a capability" do
      capability.disable
      is_expected.to_not be_enabled
    end
  end
end
