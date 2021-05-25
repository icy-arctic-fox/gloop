require "../spec_helper"

Spectator.describe Gloop::Debug do
  before_all { init_opengl }
  after_all { terminate_opengl }

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

  describe ".log" do
    before_each { described_class.enable }
    after_each { described_class.disable }

    it "produces a debug message" do
      message = nil
      Gloop::Debug.on_message { |received| message = received }
      Gloop::Debug.log(:high,
         type: :performance,
         source: :application,
         id: 12345) { "Test message" }

      expect(message).to be_a(Gloop::Debug::Message)
      expect(message.not_nil!).to have_attributes(
        source: Gloop::Debug::Source::Application,
        type: Gloop::Debug::Type::Performance,
        id: 12345,
        severity: Gloop::Debug::Severity::High,
        message: "Test message"
      )
    end
  end

  describe ".on_message" do
    before_each { described_class.enable }
    after_each { described_class.disable }

    let(message) do
      Gloop::Debug::Message.new(
        Gloop::Debug::Source::Application,
        Gloop::Debug::Type::Other,
        12345,
        Gloop::Debug::Severity::Notification,
        "Test message"
      )
    end

    it "sets up a callback for debug messages" do
      called = false
      Gloop::Debug.on_message { called = true }
      message.insert
      expect(called).to be_true
    end
  end
end
