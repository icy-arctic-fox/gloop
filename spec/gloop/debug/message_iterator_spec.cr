require "../../spec_helper"

Spectator.describe Gloop::Debug::MessageIterator do
  describe "#next" do
    subject { super.next }

    before_each { Gloop::Debug.enable }
    before_each { Gloop::Debug.enable_sync }
    after_each { Gloop::Debug.disable }

    let(expected_message) { Gloop::Debug::Message.new(:third_party, :performance, 12345_u32, :high, "Test message") }
    before_each { expected_message.insert }

    it "retrieves the next message" do
      is_expected.to eq(expected_message)
    end

    it "returns a stop instance when there are no more messages" do
      described_class.new.next # Remove existing message.
      is_expected.to be_a(Iterator::Stop)
    end
  end
end
