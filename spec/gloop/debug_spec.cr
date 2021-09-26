require "../spec_helper"

private macro configure_debug_messaging
  before_each do
    debug.enable
    debug.enable_sync
  end

  after_each do
    debug.clear_on_message
    debug.disable
  end
end

private macro clear_debug_log
  before_each { debug.clear }
  after_each { debug.clear }
end

private macro track_debug_messages
  getter received = [] of Gloop::Debug::Message

  before_each do
    debug.on_message { |message| @received << message }
  end

  after_each { debug.clear_on_message }
end

Spectator.describe Gloop::Debug do
  subject(debug) { described_class.new(context) }

  describe "#enable" do
    before_each { debug.disable }

    it "enables debug output" do
      expect(&.enable).to change(&.enabled?).from(false).to(true)
    end
  end

  describe "#disable" do
    before_each { debug.enable }

    it "disables debug output" do
      expect(&.disable).to change(&.enabled?).from(true).to(false)
    end
  end

  describe "#enabled=" do
    context "when true" do
      before_each { debug.disable }

      it "enables debug output" do
        expect { debug.enabled = true }.to change(&.enabled?).from(false).to(true)
      end
    end

    context "when false" do
      before_each { debug.enable }

      it "disables debug output" do
        expect { debug.enabled = false }.to change(&.enabled?).from(true).to(false)
      end
    end
  end

  describe "#enable_sync" do
    before_each { debug.disable_sync }

    it "enables synchronized debug output" do
      expect(&.enable_sync).to change(&.sync?).from(false).to(true)
    end
  end

  describe "#disable_sync" do
    before_each { debug.enable_sync }

    it "disables synchronized debug output" do
      expect(&.disable_sync).to change(&.sync?).from(true).to(false)
    end
  end

  describe "#sync=" do
    context "when true" do
      before_each { debug.disable_sync }

      it "enables synchronized debug output" do
        expect { debug.sync = true }.to change(&.sync?).from(false).to(true)
      end
    end

    context "when false" do
      before_each { debug.enable_sync }

      it "disables synchronized debug output" do
        expect { debug.sync = false }.to change(&.sync?).from(true).to(false)
      end
    end
  end

  describe "#reject" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    # Re-enable all message types.
    after_each { debug.allow }

    it "blocks messages of a specific source and type" do
      # Block one type of message.
      debug.reject(source: :application, type: :performance, severity: :high)

      # This message should not be received.
      debug.log("#reject", severity: :high, source: :application, type: :performance)

      # This message should be received.
      debug.log("#reject", severity: :high, type: :undefined_behavior)

      expected_message = Gloop::Debug::Message.new(:application, :undefined_behavior, 0, :high, "#reject")
      expect(received).to contain_exactly(expected_message)
    end

    it "blocks messages wight specifc IDs" do
      # Allow one type of message.
      debug.reject(source: :application, type: :performance, ids: [12345_u32])

      # This message should not be received.
      debug.log("#reject IDs", severity: :high, source: :application, type: :performance, id: 12345)

      # This message should be received.
      debug.log("#reject IDs", severity: :high, type: :undefined_behavior, id: 12345)

      expected_message = Gloop::Debug::Message.new(:application, :undefined_behavior, 12345, :high, "#reject IDs")
      expect(received).to contain_exactly(expected_message)
    end
  end

  describe "#allow" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    before_each do
      # Disable all message types.
      debug.reject(
        source: :dont_care,
        type: :dont_care,
        severity: :dont_care
      )
    end

    # Re-enable all message types.
    after_each { debug.allow }

    it "allows messages of a specific source and type to be received" do
      # Allow one type of message.
      # It should be the only message received.
      debug.allow(source: :application, type: :performance, severity: :high)

      # This message should not be received.
      debug.log("#allow", severity: :high, type: :undefined_behavior)

      # This message should be received.
      debug.log("#allow", severity: :high, source: :application, type: :performance)

      expected_message = Gloop::Debug::Message.new(:application, :performance, 0, :high, "#allow")
      expect(received).to contain_exactly(expected_message)
    end

    it "allows messages with specific IDs to be received" do
      # Allow one type of message.
      # It should be the only message received.
      debug.allow(source: :application, type: :performance, ids: [12345_u32])

      # This message should not be received.
      debug.log("#allow IDs", severity: :high, type: :undefined_behavior, id: 12345)

      # This message should be received.
      debug.log("#allow IDs", severity: :high, source: :application, type: :performance, id: 12345)

      expected_message = Gloop::Debug::Message.new(:application, :performance, 12345, :high, "#allow IDs")
      expect(received).to contain_exactly(expected_message)
    end
  end

  describe "#log" do
    configure_debug_messaging
    clear_debug_log

    it "produces a debug message" do
      message = nil
      debug.on_message { |received| message = received }
      debug.log("#log",
        severity: :high,
        type: :performance,
        source: :application,
        id: 12345)

      expect(message).to have_attributes(
        source: Gloop::Debug::Source::Application,
        type: Gloop::Debug::Type::Performance,
        id: 12345,
        severity: Gloop::Debug::Severity::High,
        message: "#log"
      )
    end
  end

  describe "#push" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    it "sends a debug message" do
      expected_message = Gloop::Debug::Message.new(:third_party, :push_group, 12345, :notification, "#push")
      debug.push("#push", source: :third_party, id: 12345)

      begin
        expect(received).to contain_exactly(expected_message)
      ensure
        # Make sure the group is popped to prevent stack problems.
        debug.pop
      end
    end
  end

  describe "#pop" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    before_each { debug.push("#pop", source: :third_party, id: 12345) }

    it "sends a debug message" do
      expected_message = Gloop::Debug::Message.new(:third_party, :pop_group, 12345, :notification, "#pop")
      debug.pop
      expect(received).to end_with(expected_message)
    end
  end

  describe "#group" do
    configure_debug_messaging
    track_debug_messages
    clear_debug_log

    it "pushes and pops debug groups" do
      push_message = Gloop::Debug::Message.new(:third_party, :push_group, 12345, :notification, "#group")
      pop_message = Gloop::Debug::Message.new(:third_party, :pop_group, 12345, :notification, "#group")
      debug.group("#group", source: :third_party, id: 12345) do
        # ...
      end
      expect(received).to contain_exactly(push_message, pop_message).in_order
    end

    it "yields" do
      yielded = false
      debug.group("Start group") { yielded = true }
      expect(yielded).to be_true
    end

    it "ensures the group is popped" do
      pop_message = Gloop::Debug::Message.new(:third_party, :pop_group, 12345, :notification, "#group")
      begin
        debug.group("#group", source: :third_party, id: 12345) do
          raise "oops"
        end
      rescue
        # ...
      end
      expect(received).to contain(pop_message)
    end
  end

  describe "#on_message" do
    configure_debug_messaging

    let(message) do
      Gloop::Debug::Message.new(:application, :other, 12345, :notification, "#on_message")
    end

    it "sets up a callback for debug messages" do
      called = false
      debug.on_message { called = true }
      message.insert(context)
      expect(called).to be_true
    end
  end

  describe "#clear_on_message" do
    configure_debug_messaging
    clear_debug_log

    it "stops messages from being sent to the callback" do
      called = false
      debug.on_message { called = true }
      debug.clear_on_message
      debug.log("#clear_on_message")
      expect(called).to be_false
    end
  end
end
