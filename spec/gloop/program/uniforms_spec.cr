require "../../spec_helper"

Spectator.describe Gloop::Program::Uniforms do
  subject(uniforms) { Gloop::Program::Uniforms.new(context, program.name) }

  SHADER_SOURCE = <<-END_SHADER
    #version 460 core
    layout (location = 3) uniform float color;
    out vec4 FragColor;
    void main() {
        FragColor = vec4(color, color, color, 1.0);
    }
    END_SHADER

  let(shader) do
    Gloop::Shader.create(context, :fragment).tap do |shader|
      shader.source = SHADER_SOURCE
      shader.compile!
    end
  end

  let(program) do
    Gloop::Program.create(context).tap do |program|
      program.attach(shader)
      program.link!
    end
  end

  after_each { program.delete }

  describe "#locate" do
    subject { uniforms.locate(name) }
    let(name) { "color" }

    context "with an existing uniform" do
      it "returns the location of the uniform" do
        is_expected.to eq(3)
      end
    end

    context "with a non-existent uniform" do
      let(name) { "foobar" }

      it "returns -1" do
        is_expected.to eq(-1)
      end
    end
  end

  describe "#locate?" do
    subject { uniforms.locate?(name) }
    let(name) { "color" }

    context "with an existing uniform" do
      it "returns the location of the uniform" do
        is_expected.to eq(3)
      end
    end

    context "with a non-existent uniform" do
      let(name) { "foobar" }

      it "returns nil" do
        is_expected.to be_nil
      end
    end
  end

  describe "#locate!" do
    subject { uniforms.locate!(name) }
    let(name) { "color" }

    context "with an existing uniform" do
      it "returns the location of the uniform" do
        is_expected.to eq(3)
      end
    end

    context "with a non-existent uniform" do
      it "raises an error" do
        expect { uniforms.locate!("foobar") }.to raise_error(/uniform/)
      end
    end
  end

  describe "#[]" do
    context "with a location" do
      it "returns a uniform with the specified location" do
        uniform = uniforms[5]
        expect(uniform.location).to eq(5)
      end
    end

    context "with a name" do
      it "returns a uniform with its location" do
        uniform = uniforms["color"]
        expect(uniform.location).to eq(3)
      end
    end

    context "with a non-existent name" do
      it "raises an error" do
        expect { uniforms["foobar"] }.to raise_error(/uniform/)
      end
    end
  end

  describe "#[]?" do
    context "with an existing uniform" do
      it "returns the uniform with its location" do
        uniform = uniforms["color"]?
        expect(uniform).to_not be_nil
        expect(uniform).to have_attributes(location: 3)
      end
    end

    context "with a non-existent uniform" do
      it "returns nil" do
        uniform = uniforms["foobar"]?
        expect(uniform).to be_nil
      end
    end
  end
end

Spectator.describe Gloop::Program do
  let(program) { Gloop::Program.create(context) }

  describe "#uniforms" do
    subject { program.uniforms }

    it "returns a set of uniforms" do
      is_expected.to be_a(Gloop::Program::Uniforms)
    end
  end
end
