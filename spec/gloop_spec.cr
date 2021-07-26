require "./spec_helper"

Spectator.describe Gloop do
  let(capability) { Gloop::Capability::Blend }

  describe ".enable" do
    it "enables capabilities" do
      Gloop.enable(capability)
      expect { Gloop.enabled?(capability) }.to be_true
    end
  end

  describe ".disable" do
    it "disables capabilities" do
      Gloop.disable(capability)
      expect { Gloop.enabled?(capability) }.to be_false
    end
  end
end
