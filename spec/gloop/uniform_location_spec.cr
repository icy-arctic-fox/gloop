require "../spec_helper"

Spectator.describe Gloop::UniformLocation do
  subject(uniform) { described_class.new(context, 0) }

  def shader_source(type)
    <<-END_SHADER
      #version 460 core
      layout (location = 0) uniform #{type} color;
      out vec4 FragColor;
      void main() {
          FragColor = vec4(color, color, color, 1.0);
      }
      END_SHADER
  end

  let(type) { :float }

  let(shader) do
    Gloop::Shader.create(context, :fragment).tap do |shader|
      shader.source = shader_source(type)
      shader.compile!
    end
  end

  let(program) do
    Gloop::Program.create(context).tap do |program|
      program.attach(shader)
      program.link!
    end
  end

  before_each { program.use }
  after_each { program.delete }

  describe "#value=" do
    context "with a Float32" do
      let(type) { :float }

      it "updates a uniform" do
        expect { uniform.value = 0.75_f32 }.to change { program.uniforms[0].value_as(Float32) }.to(0.75)
      end
    end

    context "with a Float64" do
      let(type) { :double }

      it "updates a uniform" do
        expect { uniform.value = 0.75 }.to change { program.uniforms[0].value_as(Float64) }.to(0.75)
      end
    end

    context "with a Int32" do
      let(type) { :int }

      it "updates a uniform" do
        expect { uniform.value = 42 }.to change { program.uniforms[0].value_as(Int32) }.to(42)
      end
    end

    context "with a UInt32" do
      let(type) { :uint }

      it "updates a uniform" do
        expect { uniform.value = 12345_u32 }.to change { program.uniforms[0].value_as(UInt32) }.to(12345_u32)
      end
    end
  end
end
