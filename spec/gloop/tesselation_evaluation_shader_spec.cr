require "../spec_helper"

Spectator.describe Gloop::TessellationEvaluationShader do
  subject(valid_shader) { described_class.compile(context, VALID_SHADER) }
  subject(invalid_shader) { described_class.compile(context, INVALID_SHADER) }
  subject(uncompiled_shader) { described_class.create(context) }

  # Shader code taken from here:
  # https://voxels.blogspot.com/2011/09/tesselation-shader-tutorial-with-source.html
  VALID_SHADER = <<-END_SHADER
    #version 410 core

    layout(quads, equal_spacing, ccw) in;

    //quad interpol
    vec4 interpolate(in vec4 v0, in vec4 v1, in vec4 v2, in vec4 v3)
    {
      vec4 a = mix(v0, v1, gl_TessCoord.x);
      vec4 b = mix(v3, v2, gl_TessCoord.x);
      return mix(a, b, gl_TessCoord.y);
    }

    void main()
    {
      gl_Position = interpolate(
        gl_in[0].gl_Position,
        gl_in[1].gl_Position,
        gl_in[2].gl_Position,
        gl_in[3].gl_Position);
    }
  END_SHADER

  INVALID_SHADER = <<-END_SHADER
    asdf;
  END_SHADER

  describe ".type" do
    subject { described_class.type }

    it "is TessellationEvaluation" do
      is_expected.to eq(Gloop::Shader::Type::TessellationEvaluation)
    end
  end

  describe "#type" do
    subject { super.type }

    it "is TessellationEvaluation" do
      is_expected.to eq(Gloop::Shader::Type::TessellationEvaluation)
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
      let(shader) { described_class.new(context, 0_u32) } # Zero is an invalid shader name.
      it { is_expected.to be_false }
    end

    context "with an existing shader" do
      let(shader) { uncompiled_shader }
      it { is_expected.to be_true }
    end
  end

  describe "#compile" do
    context "with a valid shader" do
      before_each { subject.source = VALID_SHADER }

      it "compiles successfully" do
        expect(&.compile).to be_true
      end
    end

    context "multiple source strings" do
      before_each { subject.sources = VALID_SHADER.lines(false) }

      it "compiles successfully" do
        expect(&.compile).to be_true
      end
    end

    context "with an invalid shader" do
      before_each { subject.source = INVALID_SHADER }

      it "fails to compile" do
        expect(&.compile).to be_false
      end
    end
  end

  describe "#compile!" do
    context "with a valid shader" do
      before_each { subject.source = VALID_SHADER }

      it "compiles successfully" do
        subject.compile!
        expect(&.compiled?).to be_true
      end
    end

    context "multiple source strings" do
      before_each { subject.sources = VALID_SHADER.lines(false) }

      it "compiles successfully" do
        subject.compile!
        expect(&.compiled?).to be_true
      end
    end

    context "with an invalid shader" do
      before_each { subject.source = INVALID_SHADER }

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
      is_expected.to eq(shader.info_log.not_nil!.size)
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
      is_expected.to eq(shader.source.not_nil!.size)
    end
  end

  context "Labelable" do
    subject { uncompiled_shader }

    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end
