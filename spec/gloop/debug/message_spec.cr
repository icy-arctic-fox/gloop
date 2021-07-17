require "../../spec_helper"

Spectator.describe Gloop::Debug::Message do
  describe ".max_size" do
    it "is the maximum message length" do
      pname = LibGL::GetPName.new(LibGL::MAX_DEBUG_MESSAGE_LENGTH.to_u32)
      LibGL.get_integer_v(pname, out length)
      expect(described_class.max_size).to eq(length)
    end
  end

  describe "#initialize" do
    it "sets the attributes" do
      message = described_class.new(
        Gloop::Debug::Source::Application,
        Gloop::Debug::Type::Other,
        12345,
        Gloop::Debug::Severity::Notification,
        "Test message"
      )

      expect(message).to have_attributes(
        source: Gloop::Debug::Source::Application,
        type: Gloop::Debug::Type::Other,
        id: 12345,
        severity: Gloop::Debug::Severity::Notification,
        message: "Test message"
      )
    end
  end
end
