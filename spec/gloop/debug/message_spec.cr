require "../../spec_helper"

Spectator.describe Gloop::Debug::Message do
  before_all { init_opengl }
  after_all { terminate_opengl }

  describe ".max_size" do
    it "is the maximum message length" do
      pname = LibGL::GetPName.new(LibGL::MAX_DEBUG_MESSAGE_LENGTH.to_u32)
      LibGL.get_integer_v(pname, out length)
      expect(described_class.max_size).to eq(length)
    end
  end
end
