require "../../spec_helper"

Spectator.describe Gloop::Debug::Message do
  subject(message) do
    described_class.new(:application, :other, 12345, :notification, "Test message")
  end
  let(debug) { Gloop::Debug.new(context) }

  describe "#initialize" do
    it "sets the attributes" do
      is_expected.to have_attributes(
        source: Gloop::Debug::Source::Application,
        type: Gloop::Debug::Type::Other,
        id: 12345,
        severity: Gloop::Debug::Severity::Notification,
        message: "Test message"
      )
    end
  end

  describe "#insert" do
    before_each { debug.clear }
    after_each { debug.clear_on_message }

    it "logs the message" do
      received = nil.as(Gloop::Debug::Message?)
      debug.on_message { |message| received = message }

      message.insert(context)
      expect(received).to_not be_nil, "Did not receive debug message"

      expect(received).to have_attributes(
        source: Gloop::Debug::Source::Application,
        type: Gloop::Debug::Type::Other,
        id: 12345,
        severity: Gloop::Debug::Severity::Notification,
        message: "Test message"
      )
    end
  end

  describe "#to_s" do
    subject { message.to_s }

    it "contains the attributes" do
      aggregate_failures "attributes" do
        is_expected.to contain("Application"), "Missing source"
        is_expected.to contain("Other"), "Missing type"
        is_expected.to contain("12345"), "Missing ID"
        is_expected.to contain("Notification"), "Missing severity"
        is_expected.to contain("Test message"), "Missing message"
      end
    end
  end
end
