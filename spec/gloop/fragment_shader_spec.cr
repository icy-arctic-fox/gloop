require "../spec_helper"

Spectator.describe Gloop::FragmentShader do
  before_all { init_opengl }
  after_all { terminate_opengl }

  subject(valid_shader) { described_class.compile(VALID_FRAGMENT_SHADER) }
  subject(invalid_shader) { described_class.compile(INVALID_FRAGMENT_SHADER) }
  subject(uncompiled_shader) { described_class.create }

  VALID_FRAGMENT_SHADER =<<-END_SHADER
    #version 460 core
    out vec4 FragColor;
    in vec4 VertColor;
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

  describe "#compile" do
    context "with a valid shader" do
      before_each do
        subject.source = VALID_FRAGMENT_SHADER
        subject.compile
      end

      it "compiles successfully" do
        expect(&.compiled?).to be_true
      end
    end

    context "with an invalid shader" do
      before_each do
        subject.source = INVALID_FRAGMENT_SHADER
        subject.compile
      end

      it "fails to compile" do
        expect(&.compiled?).to be_false
      end
    end
  end

  describe "#compile!" do
    context "with a valid shader" do
      before_each do
        subject.source = VALID_FRAGMENT_SHADER
        subject.compile!
      end

      it "compiles successfully" do
        expect(&.compiled?).to be_true
      end
    end

    context "with an invalid shader" do
      before_each do
        subject.source = INVALID_FRAGMENT_SHADER
      end

      it "raises an error" do
        expect(&.compile!).to raise_error(Gloop::ShaderCompilationError)
      end
    end
  end

  describe "#info_log" do
    before_each do
      subject.source = INVALID_FRAGMENT_SHADER
      subject.compile
    end

    it "contains information after a failed compilation" do
      expect(&.info_log).to_not be_empty
    end
  end

  describe "#info_log_size" do
    before_each do
      subject.source = INVALID_FRAGMENT_SHADER
      subject.compile
    end

    it "is the size of the info log" do
      expect(&.info_log_size).to eq(subject.info_log.size + 1) # +1 for null-terminator byte.
    end
  end
end
