require "../spec_helper"

Spectator.describe Gloop::VertexShader do
  before_all { init_opengl }
  after_all { terminate_opengl }

  subject(valid_shader) { described_class.compile(VALID_SHADER) }
  subject(invalid_shader) { described_class.compile(INVALID_SHADER) }
  subject(uncompiled_shader) { described_class.create }

  VALID_SHADER = <<-END_SHADER
    #version 460 core
    in vec3 Position;
    out vec4 Color;
    void main() {
      gl_Position = vec4(Position, 1.0);
      Color = vec4(0.03, 0.39, 0.57, 1.0);
    }
  END_SHADER

  INVALID_SHADER = <<-END_SHADER
    asdf;
  END_SHADER

  describe ".type" do
    subject { described_class.type }

    it "is Vertex" do
      is_expected.to eq(Gloop::Shader::Type::Vertex)
    end
  end

  describe "#type" do
    subject { super.type }

    it "is Vertex" do
      is_expected.to eq(Gloop::Shader::Type::Vertex)
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
        subject.source = VALID_SHADER
        subject.compile
      end

      it "compiles successfully" do
        expect(&.compiled?).to be_true
      end
    end

    context "multiple source strings" do
      before_each do
        subject.sources = VALID_SHADER.lines(false)
        subject.compile
      end

      it "compiles successfully" do
        expect(&.compiled?).to be_true
      end
    end

    context "with an invalid shader" do
      before_each do
        subject.source = INVALID_SHADER
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
        subject.source = VALID_SHADER
      end

      it "compiles successfully" do
        subject.compile!
        expect(&.compiled?).to be_true
      end
    end

    context "multiple source strings" do
      before_each do
        subject.sources = VALID_SHADER.lines(false)
      end

      it "compiles successfully" do
        subject.compile!
        expect(&.compiled?).to be_true
      end
    end

    context "with an invalid shader" do
      before_each do
        subject.source = INVALID_SHADER
      end

      it "raises an error" do
        expect(&.compile!).to raise_error(Gloop::ShaderCompilationError)
      end
    end
  end

  describe "#info_log" do
    before_each do
      subject.source = INVALID_SHADER
      subject.compile
    end

    it "contains information after a failed compilation" do
      expect(&.info_log).to_not be_empty
    end
  end

  describe "#info_log_size" do
    let(shader) { invalid_shader }
    subject { shader.info_log_size }

    it "is the size of the info log" do
      is_expected.to eq(shader.info_log.size + 1) # +1 for null-terminator byte.
    end
  end

  describe "#source" do
    let(shader) { uncompiled_shader }
    subject { shader.source }

    before_each do
      shader.source = VALID_SHADER
    end

    it "contains the source code" do
      is_expected.to eq(VALID_SHADER)
    end
  end

  describe "#source_size" do
    let(shader) { uncompiled_shader }
    subject { shader.source_size }

    before_each do
      shader.source = VALID_SHADER
    end

    it "is the size of the source code" do
      is_expected.to eq(shader.source.size + 1) # +1 for null-terminator byte.
    end
  end
end
