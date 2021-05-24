require "../spec_helper"

Spectator.describe Gloop::Debug do
  before_all { init_opengl }
  after_all { terminate_opengl }

  # before_each { described_class.enable }
  # after_each { described_class.disable }

  describe "#on_message" do
    xit "sets up a callback for debug messages" do
      called = false
      Gloop::Debug.on_message do |message|
        called = true
      end
      expect(called).to be_true
    end
  end
end
