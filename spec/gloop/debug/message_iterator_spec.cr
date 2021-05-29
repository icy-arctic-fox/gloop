require "../../spec_helper"

Spectator.describe Gloop::Debug::MessageIterator do
  before_each { Gloop::Debug.enable }
  before_each { Gloop::Debug.enable_sync }
  after_each { Gloop::Debug.disable }

  describe "#next" do
    subject { super.next }

    let(expected_message) { Gloop::Debug::Message.new(:third_party, :performance, 12345_u32, :high, "#next") }
    before_each { expected_message.insert }

    it "retrieves the next message" do
      is_expected.to eq(expected_message)
    end

    it "returns a stop instance when there are no more messages" do
      described_class.new.next # Remove existing message.
      is_expected.to be_a(Iterator::Stop)
    end
  end

  describe "#size" do
    subject { super.size }
    let(count) { 2 }
    before_each { count.times { Gloop::Debug.log(:high) { "#size" } } }
    after_each { Gloop::Debug.messages } # Dump messages from log after testing.

    it "is the number of messages in the debug log" do
      is_expected.to eq(count)
    end
  end
end
