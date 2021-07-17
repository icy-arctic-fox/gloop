require "../../spec_helper"

Spectator.describe Gloop::Debug::MessageIterator do
  before_each do
    Gloop::Debug.enable
    Gloop::Debug.enable_sync
    Gloop::Debug.clear
  end

  after_each do
    Gloop::Debug.clear
    Gloop::Debug.disable
  end

  describe "#next" do
    subject { super.next }

    let(expected_message) { Gloop::Debug::Message.new(:third_party, :performance, 12345_u32, :high, "#next") }
    before_each { expected_message.insert }

    it "retrieves the next message" do
      is_expected.to eq(expected_message)
    end

    it "returns a stop instance when there are no more messages" do
      Gloop::Debug.clear # Remove existing message.
      is_expected.to be_a(Iterator::Stop)
    end
  end

  describe "#size" do
    subject { super.size }
    let(count) { 2 }
    before_each do
      count.times { Gloop::Debug.log(:high) { "#size" } }
    end

    it "is the number of messages in the debug log" do
      is_expected.to eq(count)
    end
  end
end
