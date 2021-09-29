require "../spec_helper"

VERTEX_SHADER = <<-END_SHADER
  #version 460 core
  in vec3 Position;
  out vec4 VertColor;
  void main() {
    gl_Position = vec4(Position, 1.0);
    VertColor = vec4(0.03, 0.39, 0.57, 1.0);
  }
END_SHADER

FRAGMENT_SHADER = <<-END_SHADER
  #version 460 core
  out vec4 FragColor;
  in vec4 VertColor;
  void main() {
    FragColor = VertColor;
  }
END_SHADER

Spectator.describe Gloop::Program do
  subject(program) { described_class.create(context) }

  def current_program
    described_class.current(context)
  end

  let(vertex_shader) do
    Gloop::Shader.create(context, :vertex).tap do |shader|
      shader.source = VERTEX_SHADER
      shader.compile!
    end
  end

  let(fragment_shader) do
    Gloop::Shader.create(context, :fragment).tap do |shader|
      shader.source = FRAGMENT_SHADER
      shader.compile!
    end
  end

  # TODO: Test program parameters.

  describe ".current?" do
    subject { described_class.current?(context) }

    before_each do
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link
    end

    it "is the currently active program" do
      program.use
      is_expected.to eq(program)
    end

    it "is nil when no program is active" do
      described_class.uninstall(context)
      is_expected.to be_nil
    end
  end

  describe ".current" do
    subject { current_program }

    before_each do
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link
    end

    it "is the currently active program" do
      program.use
      is_expected.to eq(program)
    end

    it "is the null object when no program is active" do
      described_class.uninstall(context)
      is_expected.to be_none
    end
  end

  describe ".none" do
    subject { described_class.none(context) }

    it "is a null object" do
      expect(&.none?).to be_true
    end
  end

  describe "#delete" do
    it "deletes a program" do
      subject.delete
      expect(&.exists?).to be_false
    end
  end

  describe "#exists?" do
    subject { program.exists? }

    context "with a non-existent program" do
      let(program) { described_class.new(context, 0_u32) } # Zero is an invalid program name.
      it { is_expected.to be_false }
    end

    context "with an existing program" do
      it { is_expected.to be_true }
    end
  end

  describe "#attach" do
    let(shader) { Gloop::Shader.create(context, :vertex) }

    it "attaches a shader" do
      program.attach(shader)
      expect(&.shaders).to contain(shader)
    end
  end

  describe "#detach" do
    let(shader) { Gloop::Shader.create(context, :vertex) }

    before_each { program.attach(shader) }

    it "detaches a shader" do
      program.detach(shader)
      expect(&.shaders).to_not contain(shader)
    end
  end

  describe "#link" do
    context "with a valid program" do
      before_each do
        program.attach(vertex_shader)
        program.attach(fragment_shader)
      end

      it "succeeds" do
        expect(&.link).to be_true
      end
    end

    context "with an invalid program" do
      it "fails" do
        expect(&.link).to be_false
      end
    end
  end

  context "link error" do
    let(invalid_vertex_shader) do
      Gloop::Shader.create(context, :vertex).tap do |shader|
        shader.source = <<-END_SHADER
          #version 460 core
          in vec3 Position;
          out vec4 VertColor;
          void main() {
            gl_Position = vec4(Position, 1.0);
            VertColor = vec4(0.03, 0.39, 0.57, 1.0);
          }
        END_SHADER
        shader.compile!
      end
    end

    let(invalid_fragment_shader) do
      Gloop::Shader.create(context, :fragment).tap do |shader|
        shader.source = <<-END_SHADER
          #version 460 core
          out vec4 FragColor;
          in vec4 BadVertColor;
          void main() {
            FragColor = BadVertColor;
          }
        END_SHADER
        shader.compile!
      end
    end

    before_each do
      program.attach(invalid_vertex_shader)
      program.attach(invalid_fragment_shader)
      program.link
    end

    describe "#info_log" do
      it "contains information after a failed link" do
        expect(&.info_log).to_not be_empty
      end
    end

    describe "#info_log_size" do
      subject { super.info_log_size }

      it "is the size of the info log" do
        is_expected.to eq(program.info_log.not_nil!.size)
      end
    end
  end

  describe "#use" do
    before_each do
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link!
    end

    it "installs the program" do
      program.use
      expect(current_program).to eq(program)
    end

    context "block syntax" do
      let(previous) { described_class.create(context) }

      before_each do
        previous.attach(vertex_shader)
        previous.attach(fragment_shader)
        previous.link!
      end

      it "resets to the previous program" do
        previous.use
        program.use { }
        expect(current_program).to eq(previous)
      end

      it "resets to the previous program on error" do
        previous.use
        begin
          program.use { raise "oops" }
        rescue Exception
          expect(current_program).to eq(previous)
        else
          fail "#use did not yield"
        end
      end
    end
  end

  describe ".uninstall" do
    before_each do
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link!
    end

    it "clears the current program" do
      program.use
      described_class.uninstall(context)
      expect(current_program).to be_none
    end
  end

  describe "#validate" do
    before_each do
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link!
    end

    it "validates the program" do
      expect { program.validate }.to eq(program.valid?)
    end
  end

  describe "#binary" do
    subject { program.binary }

    before_each do
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link!
    end

    def program_binary
      capacity = 0
      size = 0
      format = 0_u32
      context.gl.get_program_iv(program.to_unsafe, LibGL::ProgramPropertyARB::ProgramBinaryLength, pointerof(capacity))

      buffer = Bytes.new(capacity)
      context.gl.get_program_binary(
        program.to_unsafe,
        capacity,
        pointerof(size),
        pointerof(format),
        buffer.to_unsafe.as(Void*)
      )

      {format, buffer}
    end

    it "retrieves the program binary" do
      format, buffer = program_binary
      aggregate_failures "binary properties" do
        expect(&.bytes).to eq(buffer)
        expect(&.format).to eq(format)
      end
    end
  end

  describe "#binary=" do
    let(source_program) do
      described_class.create(context).tap do |program|
        program.attach(vertex_shader)
        program.attach(fragment_shader)
        program.link!
      end
    end

    let(source_binary) { source_program.binary }

    it "loads the program from binary data" do
      program.binary = source_binary
      expect(&.binary).to eq(source_program.binary)
    end
  end

  describe ".from_binary" do
    let(source_program) do
      described_class.create(context).tap do |program|
        program.attach(vertex_shader)
        program.attach(fragment_shader)
        program.link!
      end
    end

    let(source_binary) { source_program.binary }

    it "loads the program from binary data" do
      program = described_class.from_binary(context, source_binary)
      expect(program.binary).to eq(source_binary)
    end
  end

  context "Labelable" do
    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end

Spectator.describe Spectator::Context do
  let(program) { context.create_program }

  let(vertex_shader) do
    Gloop::Shader.create(context, :vertex).tap do |shader|
      shader.source = VERTEX_SHADER
      shader.compile!
    end
  end

  let(fragment_shader) do
    Gloop::Shader.create(context, :fragment).tap do |shader|
      shader.source = FRAGMENT_SHADER
      shader.compile!
    end
  end

  before_each do
    program.attach(vertex_shader)
    program.attach(fragment_shader)
    program.link
  end

  describe "#program?" do
    subject { context.program? }

    it "is the currently active program" do
      program.use
      is_expected.to eq(program)
    end

    it "is nil when no program is active" do
      context.uninstall_program
      is_expected.to be_nil
    end
  end

  describe "#program" do
    subject { context.program }

    it "is the currently active program" do
      program.use
      is_expected.to eq(program)
    end

    it "is the null object when no program is active" do
      context.uninstall_program
      is_expected.to be_none
    end
  end
end
