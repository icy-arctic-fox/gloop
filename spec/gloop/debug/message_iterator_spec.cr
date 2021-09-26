require "../../spec_helper"

Spectator.describe Gloop::Debug::MessageIterator do
  let(debug) { Gloop::Debug.new(context) }
  subject(iterator) { described_class.new(context) }

  before_each do
    debug.enable
    debug.enable_sync
    debug.clear
  end

  after_each do
    debug.clear
    debug.disable
    debug.disable_sync
  end

  describe "#next" do
    subject { iterator.next }

    let(expected_message) { Gloop::Debug::Message.new(:third_party, :performance, 12345, :high, "#next") }
    before_each { expected_message.insert(context) }

    it "retrieves the next message" do
      is_expected.to eq(expected_message)
    end

    it "returns a stop instance when there are no more messages" do
      debug.clear # Remove existing message.
      is_expected.to be_a(Iterator::Stop)
    end
  end

  describe "#first" do
    let(messages) do
      Array.new(5) { |i| Gloop::Debug::Message.new(:third_party, :performance, i.to_u32, :high, "#first") }
    end

    before_each { messages.each(&.insert(context)) }

    it "returns a subset of the log" do
      expect(&.first(3)).to match_array(messages[0...3]).in_order
    end

    it "restricts to the amount in the log" do
      expect(&.first(7)).to match_array(messages).in_order
    end
  end

  describe "#size" do
    subject { iterator.size }
    let(count) { 2 }

    before_each do
      count.times { debug.log("#size") }
    end

    it "is the number of messages in the debug log" do
      is_expected.to eq(count)
    end
  end

  describe "#empty?" do
    subject { iterator.empty? }

    it "is true when there are no messages" do
      is_expected.to be_true
    end

    it "is false when there are messages" do
      debug.log("#empty?")
      is_expected.to be_false
    end
  end

  describe "#skip" do
    before_each do
      debug.log("first")
      debug.log("second")
    end

    it "skips one message" do
      iterator.skip # Skip "first" message.
      expect(&.next).to have_attributes(message: "second")
    end

    it "returns true when a message was skipped" do
      expect(&.skip).to be_true
      expect(&.skip).to be_true
      expect(&.skip).to be_false
    end

    context "with a count" do
      it "returns an iterator" do
        expect(&.skip(2)).to be_an(Iterator(Gloop::Debug::Message))
      end

      it "skips the indicates number of messages" do
        iter = iterator.skip(1)
        expect(iter.next).to have_attributes(message: "second")
      end
    end
  end

  describe "#clear" do
    before_each do
      3.times { debug.log("#clear") }
    end

    it "empties the debug log" do
      expect(&.clear).to change(&.size).from(3).to(0)
    end
  end

  describe "#to_a" do
    subject { iterator.to_a }
    let(messages) do
      Array.new(5) { |i| Gloop::Debug::Message.new(:third_party, :performance, i.to_u32, :high, "#first") }
    end

    before_each { messages.each(&.insert(context)) }

    it "returns an array of messages" do
      is_expected.to match_array(messages).in_order
    end
  end
end
