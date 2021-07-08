require "../spec_helper"

Spectator.describe Gloop::ComputeShader do
  before_all { init_opengl }
  after_all { terminate_opengl }

  subject(valid_shader) { described_class.compile(VALID_SHADER) }
  subject(invalid_shader) { described_class.compile(INVALID_SHADER) }
  subject(uncompiled_shader) { described_class.create }

  # Shader code taken from here:
  # https://arm-software.github.io/opengl-es-sdk-for-android/compute_intro.html
  VALID_SHADER = <<-END_SHADER
    #version 310 es

    layout(local_size_x = 128) in;
    layout(std430) buffer;

    layout(binding = 0) writeonly buffer Output {
      vec4 elements[];
    } output_data;

    layout(binding = 1) readonly buffer Input0 {
      vec4 elements[];
    } input_data0;

    layout(binding = 2) readonly buffer Input1 {
      vec4 elements[];
    } input_data1;

    void main()
    {
      uint ident = gl_GlobalInvocationID.x;
      output_data.elements[ident] = input_data0.elements[ident] * input_data1.elements[ident];
    }
  END_SHADER

  INVALID_SHADER = <<-END_SHADER
    asdf;
  END_SHADER

  describe ".type" do
    subject { described_class.type }

    it "is Compute" do
      is_expected.to eq(Gloop::Shader::Type::Compute)
    end
  end

  describe "#type" do
    subject { super.type }

    it "is Compute" do
      is_expected.to eq(Gloop::Shader::Type::Compute)
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
