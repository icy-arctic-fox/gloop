require "../spec_helper"

Spectator.describe Gloop::DrawCommands do
  subject { context }

  describe "#primitive_restart_index=" do
    it "sets the primitive restart index" do
      context.primitive_restart_index = 65535
      expect(&.primitive_restart_index).to eq(65535)
    end
  end
end
