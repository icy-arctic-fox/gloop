require "../spec_helper"

Spectator.describe Gloop::FragmentShader do
  before_all { init_opengl }
  after_all { terminate_opengl }

  subject(valid_shader) { described_class.compile(VALID_FRAGMENT_SHADER) }
  subject(invalid_shader) { described_class.compile(INVALID_FRAGMENT_SHADER) }
  subject(uncompiled_shader) { described_class.create }

  VALID_FRAGMENT_SHADER =<<-END_SHADER
    #version 460 core
    out vec4 FragColor
    in vec4 VertColor
    void main() {
      FragColor = VertColor;
    }
  END_SHADER

  INVALID_FRAGMENT_SHADER =<<-END_SHADER
    asdf;
  END_SHADER

  describe ".type" do
    subject { described_class.type }

    it "is Fragment" do
      is_expected.to eq(Gloop::Shader::Type::Fragment)
    end
  end

  describe "#type" do
    subject { super.type }

    it "is Fragment" do
      is_expected.to eq(Gloop::Shader::Type::Fragment)
    end
  end

  describe "#delete" do
    it "deletes a shader" do
      subject.delete
      expect(subject.exists?).to be_false
    end
  end

  describe "#exists?" do
    subject { shader.exists? }

    context "with a non-existent shader" do
      let(shader) { described_class.new(0_u32) } # Zero is an invalid shader name.
      it { is_expected.to be_false }
    end

    context "with an existing shader" do
      let(shader) { uncompiled_shader }
      it { is_expected.to be_true }
    end
  end
end
