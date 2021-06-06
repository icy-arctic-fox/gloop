require "../spec_helper"

Spectator.describe Gloop::Labelable do
  before_all { init_opengl }
  after_all { terminate_opengl }

  describe ".max_label_size" do
    subject { super.max_label_size }

    it "is the maximum label length" do
      LibGL.get_integer_v(LibGL::GetPName::MaxLabelLength, out size)
      is_expected.to eq(size)
    end
  end
end
