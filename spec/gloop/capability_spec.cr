require "../spec_helper"

Spectator.describe Gloop::Capability do
  subject(capability) { described_class.new(context, :blend) }

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

  describe "#enabled=" do
    context "with true" do
      before_each { capability.disable }

      it "enables the capability" do
        expect { capability.enabled = true }.to change(&.enabled?).from(false).to(true)
      end
    end

    context "with false" do
      before_each { capability.enable }

      it "disables the capability" do
        expect { capability.enabled = false }.to change(&.enabled?).from(true).to(false)
      end
    end
  end
end

Spectator.describe Gloop::Context do
  subject { context }
  let(capability) { context.capability(:blend) }

  describe "#enable" do
    before_each { capability.disable }

    it "enables a capability" do
      expect { context.enable(:blend) }.to change(&.enabled?(:blend)).from(false).to(true)
    end
  end

  describe "#disable" do
    before_each { capability.enable }

    it "disables a capability" do
      expect { context.disable(:blend) }.to change(&.enabled?(:blend)).from(true).to(false)
    end
  end
end
