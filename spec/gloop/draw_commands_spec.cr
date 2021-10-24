require "../spec_helper"

Spectator.describe Gloop::DrawCommands do
  subject { context }

  describe "#enable_primitive_restart" do
    before_each { context.disable_primitive_restart }

    it "enables primitive restart" do
      expect(&.enable_primitive_restart).to change(&.primitive_restart?).from(false).to(true)
    end
  end

  describe "#disable_primitive_restart" do
    before_each { context.enable_primitive_restart }

    it "disables primitive restart" do
      expect(&.disable_primitive_restart).to change(&.primitive_restart?).from(true).to(false)
    end
  end

  describe "#primitive_restart=" do
    context "when true" do
      before_each { context.disable_primitive_restart }

      it "enables primitive restart" do
        expect { context.primitive_restart = true }.to change(&.primitive_restart?).from(false).to(true)
      end
    end

    context "when false" do
      before_each { context.enable_primitive_restart }

      it "disables primitive restart" do
        expect { context.primitive_restart = false }.to change(&.primitive_restart?).from(true).to(false)
      end
    end
  end

  describe "#enable_primitive_restart_fixed_index" do
    before_each { context.disable_primitive_restart_fixed_index }

    it "enables primitive restart fixed index" do
      expect(&.enable_primitive_restart_fixed_index).to change(&.primitive_restart_fixed_index?).from(false).to(true)
    end
  end

  describe "#disable_primitive_restart" do
    before_each { context.enable_primitive_restart_fixed_index }

    it "disables primitive restart fixed index" do
      expect(&.disable_primitive_restart_fixed_index).to change(&.primitive_restart_fixed_index?).from(true).to(false)
    end
  end

  describe "#primitive_restart_fixed_index=" do
    context "when true" do
      before_each { context.disable_primitive_restart_fixed_index }

      it "enables primitive restart fixed index" do
        expect { context.primitive_restart_fixed_index = true }.to change(&.primitive_restart_fixed_index?).from(false).to(true)
      end
    end

    context "when false" do
      before_each { context.enable_primitive_restart_fixed_index }

      it "disables primitive restart fixed index" do
        expect { context.primitive_restart_fixed_index = false }.to change(&.primitive_restart_fixed_index?).from(true).to(false)
      end
    end
  end

  describe "#primitive_restart_index=" do
    it "sets the primitive restart index" do
      context.primitive_restart_index = 65535
      expect(&.primitive_restart_index).to eq(65535)
    end
  end
end
