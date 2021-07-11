require "../spec_helper"

Spectator.describe Gloop::Program do
  before_all { init_opengl }
  after_all { terminate_opengl }

  subject(program) { described_class.create }

  let(vertex_shader) do
    Gloop::VertexShader.compile!(<<-END_SHADER
        #version 460 core
        in vec3 Position;
        out vec4 VertColor;
        void main() {
          gl_Position = vec4(Position, 1.0);
          VertColor = vec4(0.03, 0.39, 0.57, 1.0);
        }
      END_SHADER
    )
  end

  let(fragment_shader) do
    Gloop::FragmentShader.compile!(<<-END_SHADER
        #version 460 core
        out vec4 FragColor;
        in vec4 VertColor;
        void main() {
          FragColor = VertColor;
        }
      END_SHADER
    )
  end

  describe "#delete" do
    it "deletes a program" do
      subject.delete
      expect(subject.exists?).to be_false
    end
  end

  describe "#exists?" do
    subject { program.exists? }

    context "with a non-existent program" do
      let(program) { described_class.new(0_u32) } # Zero is an invalid program name.
      it { is_expected.to be_false }
    end

    context "with an existing program" do
      it { is_expected.to be_true }
    end
  end

  describe "#attach" do
    let(shader) { Gloop::VertexShader.create }

    it "attaches a shader" do
      program.attach(shader)
      expect(&.shaders).to contain(shader)
    end
  end

  describe "#detach" do
    let(shader) { Gloop::VertexShader.create }

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
      Gloop::VertexShader.compile!(<<-END_SHADER
          #version 460 core
          in vec3 Position;
          out vec4 VertColor;
          void main() {
            gl_Position = vec4(Position, 1.0);
            VertColor = vec4(0.03, 0.39, 0.57, 1.0);
          }
        END_SHADER
      )
    end

    let(invalid_fragment_shader) do
      Gloop::FragmentShader.compile!(<<-END_SHADER
          #version 460 core
          out vec4 FragColor;
          in vec4 BadVertColor;
          void main() {
            FragColor = BadVertColor;
          }
        END_SHADER
      )
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

  describe "#activate" do
    before_each do
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link!
    end

    it "uses the program" do
      program.activate
      expect(described_class.current).to eq(program)
    end

    context "block syntax" do
      let(previous) { described_class.create }

      before_each do
        previous.attach(vertex_shader)
        previous.attach(fragment_shader)
        previous.link!
      end

      it "resets to the previous program" do
        previous.activate
        program.activate { }
        expect(described_class.current).to eq(previous)
      end

      it "resets to the previous program on error" do
        previous.activate
        begin
          program.activate { raise "oops" }
        rescue Exception
          expect(described_class.current).to eq(previous)
        else
          fail "#activate did not yield"
        end
      end
    end
  end

  describe ".deactivate" do
    subject { described_class.current }

    before_each do
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link!
    end

    it "clears the current program" do
      program.activate
      described_class.deactivate
      is_expected.to be_nil
    end
  end

  describe "#validate" do
    it "validates the program" do
      expect { program.validate }.to eq(program.valid?)
    end
  end

  context "Labelable" do
    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end
