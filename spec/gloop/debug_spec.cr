require "../spec_helper"

private macro configure_debug_messaging
  before_each do
    described_class.enable
    described_class.enable_sync
  end

  after_each do
    described_class.clear_message_listener
    described_class.disable
  end
end

private macro clear_debug_log
  before_each { Gloop::Debug.clear }
  after_each { Gloop::Debug.clear }
end

private macro track_debug_messages
  getter received = [] of Gloop::Debug::Message

  before_each do
    described_class.on_message { |message| @received << message }
  end

  after_each { described_class.clear_message_listener }
end

Spectator.describe Gloop::Debug do
  describe ".enable" do
    before_each { described_class.disable }

    it "enables debug output" do
      expect { described_class.enable }.to change(&.enabled?).from(false).to(true)
    end
  end

  describe ".disable" do
    before_each { described_class.enable }

    it "disables debug output" do
      expect { described_class.disable }.to change(&.enabled?).from(true).to(false)
    end
  end

  describe ".enabled=" do
    context "when true" do
      before_each { described_class.disable }

      it "enables debug output" do
        expect { described_class.enabled = true }.to change(&.enabled?).from(false).to(true)
      end
    end

    context "when false" do
      before_each { described_class.enable }

      it "disables debug output" do
        expect { described_class.enabled = false }.to change(&.enabled?).from(true).to(false)
      end
    end
  end

  describe ".enable_sync" do
    before_each { described_class.disable_sync }

    it "enables synchronized debug output" do
      expect { described_class.enable_sync }.to change(&.sync?).from(false).to(true)
    end
  end

  describe ".disable_sync" do
    before_each { described_class.enable_sync }

    it "disables synchronized debug output" do
      expect { described_class.disable_sync }.to change(&.sync?).from(true).to(false)
    end
  end

  describe ".sync=" do
    context "when true" do
      before_each { described_class.disable_sync }

      it "enables synchronized debug output" do
        expect { described_class.sync = true }.to change(&.sync?).from(false).to(true)
      end
    end

    context "when false" do
      before_each { described_class.enable_sync }

      it "disables synchronized debug output" do
        expect { described_class.sync = false }.to change(&.sync?).from(true).to(false)
      end
    end
  end

  describe ".message_count" do
    configure_debug_messaging
    clear_debug_log

    subject { super.message_count }

    before_each do
      described_class.log(:high) { ".message_count" }
    end

    it "returns the number of messages in queue" do
      is_expected.to eq(1)
    end
  end

  describe ".max_message_count" do
    subject { super.max_message_count }

    let(max_message_count) do
      pname = LibGL::GetPName.new(LibGL::MAX_DEBUG_LOGGED_MESSAGES.to_u32)
      LibGL.get_integer_v(pname, out value)
      value
    end

    it "returns the maximum number of messages the queue can hold" do
      is_expected.to eq(max_message_count)
    end
  end

  describe ".reject" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    # Re-enable all message types.
    after_each { described_class.allow }

    it "blocks messages of a specific source and type" do
      # Block one type of message.
      described_class.reject(source: :application, type: :performance, severity: :high)

      # This message should not be received.
      described_class.log(:high, source: :application, type: :performance) { ".reject" }

      # This message should be received.
      described_class.log(:high, type: :undefined_behavior) { ".reject" }

      expected_message = Gloop::Debug::Message.new(:application, :undefined_behavior, 0, :high, ".reject")
      expect(received).to contain_exactly(expected_message)
    end

    it "blocks messages wight specifc IDs" do
      # Allow one type of message.
      described_class.reject(source: :application, type: :performance, ids: [12345_u32])

      # This message should not be received.
      described_class.log(:high, source: :application, type: :performance, id: 12345_u32) { ".reject IDs" }

      # This message should be received.
      described_class.log(:high, type: :undefined_behavior, id: 12345_u32) { ".reject IDs" }

      expected_message = Gloop::Debug::Message.new(:application, :undefined_behavior, 12345_u32, :high, ".reject IDs")
      expect(received).to contain_exactly(expected_message)
    end
  end

  describe ".allow" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    before_each do
      # Disable all message types.
      described_class.reject(
        source: :dont_care,
        type: :dont_care,
        severity: :dont_care
      )
    end

    # Re-enable all message types.
    after_each { described_class.allow }

    it "allows messages of a specific source and type to be received" do
      # Allow one type of message.
      # It should be the only message received.
      described_class.allow(source: :application, type: :performance, severity: :high)

      # This message should not be received.
      described_class.log(:high, type: :undefined_behavior) { ".allow" }

      # This message should be received.
      described_class.log(:high, source: :application, type: :performance) { ".allow" }

      expected_message = Gloop::Debug::Message.new(:application, :performance, 0, :high, ".allow")
      expect(received).to contain_exactly(expected_message)
    end

    it "allows messages with specific IDs to be received" do
      # Allow one type of message.
      # It should be the only message received.
      described_class.allow(source: :application, type: :performance, ids: [12345_u32])

      # This message should not be received.
      described_class.log(:high, type: :undefined_behavior, id: 12345_u32) { ".allow IDs" }

      # This message should be received.
      described_class.log(:high, source: :application, type: :performance, id: 12345_u32) { ".allow IDs" }

      expected_message = Gloop::Debug::Message.new(:application, :performance, 12345_u32, :high, ".allow IDs")
      expect(received).to contain_exactly(expected_message)
    end
  end

  describe ".log" do
    configure_debug_messaging
    clear_debug_log

    it "produces a debug message" do
      message = nil
      Gloop::Debug.on_message { |received| message = received }
      Gloop::Debug.log(:high,
        type: :performance,
        source: :application,
        id: 12345) { ".log" }

      expect(message).to be_a(Gloop::Debug::Message)
      expect(message.not_nil!).to have_attributes(
        source: Gloop::Debug::Source::Application,
        type: Gloop::Debug::Type::Performance,
        id: 12345,
        severity: Gloop::Debug::Severity::High,
        message: ".log"
      )
    end
  end

  describe ".push_group" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    it "sends a debug message" do
      expected_message = Gloop::Debug::Message.new(:third_party, :push_group, 12345_u32, :notification, ".push_group")
      described_class.push_group(".push_group", source: :third_party, id: 12345_u32)

      begin
        expect(received).to contain_exactly(expected_message)
      ensure
        # Make sure the group is popped to prevent stack problems.
        described_class.pop_group
      end
    end
  end

  describe ".pop_group" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    before_each { described_class.push_group(".pop_group", source: :third_party, id: 12345_u32) }

    it "sends a debug message" do
      expected_message = Gloop::Debug::Message.new(:third_party, :pop_group, 12345_u32, :notification, ".pop_group")
      described_class.pop_group
      expect(received).to end_with(expected_message)
    end
  end

  describe ".group" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    it "pushes and pops debug groups" do
      push_message = Gloop::Debug::Message.new(:third_party, :push_group, 12345_u32, :notification, ".group")
      pop_message = Gloop::Debug::Message.new(:third_party, :pop_group, 12345_u32, :notification, ".group")
      described_class.group(".group", source: :third_party, id: 12345_u32) do
        # ...
      end
      expect(received).to contain_exactly(push_message, pop_message).in_order
    end

    it "yields" do
      yielded = false
      described_class.group("Start group") { yielded = true }
      expect(yielded).to be_true
    end

    it "ensures the group is popped" do
      pop_message = Gloop::Debug::Message.new(:third_party, :pop_group, 12345_u32, :notification, ".group")
      begin
        described_class.group(".group", source: :third_party, id: 12345_u32) do
          raise "oops"
        end
      rescue
        # ...
      end
      expect(received).to contain(pop_message)
    end
  end

  describe ".messages" do
    configure_debug_messaging
    clear_debug_log

    subject { super.messages }
    let(count) { 3 }

    before_each do
      count.times { |i| expected_message(i).insert }
    end

    def expected_message(index)
      Gloop::Debug::Message.new(:application, :other, index.to_u32, :high, ".messages")
    end

    it "retrieves all available debug messages" do
      expected_log = Array.new(count) { |i| expected_message(i) }
      is_expected.to match_array(expected_log)
    end
  end

  describe ".messages(count)" do
    configure_debug_messaging
    clear_debug_log

    subject { super.messages(count) }
    let(count) { 2 }

    before_each do
      (count + 1).times { |i| expected_message(i).insert }
    end

    def expected_message(index)
      Gloop::Debug::Message.new(:application, :other, index.to_u32, :high, ".messages(count)")
    end

    it "retrieves the specified debug messages" do
      expected_log = Array.new(count) { |i| expected_message(i) }
      is_expected.to match_array(expected_log)
    end
  end

  describe ".on_message" do
    configure_debug_messaging

    let(message) do
      Gloop::Debug::Message.new(
        Gloop::Debug::Source::Application,
        Gloop::Debug::Type::Other,
        12345,
        Gloop::Debug::Severity::Notification,
        ".on_message"
      )
    end

    it "sets up a callback for debug messages" do
      called = false
      described_class.on_message { called = true }
      message.insert
      expect(called).to be_true
    end
  end

  describe ".clear_message_listener" do
    configure_debug_messaging
    clear_debug_log

    it "stops messages from being sent to the callback" do
      called = false
      described_class.on_message { called = true }
      described_class.clear_message_listener
      described_class.log(:high) { ".clear_message_listener" }
      expect(called).to be_false
    end
  end

  describe ".clear" do
    configure_debug_messaging

    before_each do
      3.times { described_class.log(:high) { ".clear" } }
    end

    it "removes all debug messages from the log" do
      described_class.clear
      expect(&.message_count).to eq(0)
    end
  end
end
