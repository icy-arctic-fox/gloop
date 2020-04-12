require "../spec_helper"

Spectator.describe Gloop::VertexShader do
  before_all do
    LibGLFW.init
    LibGLFW.window_hint(LibGLFW::WindowHint::Visible, LibGLFW::Bool::False)
    LibGLFW.window_hint(LibGLFW::WindowHint::ContextVersionMajor, 4)
    LibGLFW.window_hint(LibGLFW::WindowHint::ContextVersionMinor, 5)
    LibGLFW.window_hint(LibGLFW::WindowHint::ClientAPI, LibGLFW::ClientAPI::OpenGL)
    LibGLFW.window_hint(LibGLFW::WindowHint::OpenGLProfile, LibGLFW::OpenGLProfile::Core)
    LibGLFW.window_hint(LibGLFW::WindowHint::OpenGLDebugContext, LibGLFW::Bool::True)
    window = LibGLFW.create_window(640, 480, "Gloop", nil, nil)
    LibGLFW.make_context_current(window)
  end

  after_all do
    LibGLFW.terminate
  end

  # Cleanup resources after each test.
  after_each { subject.delete }

  # A very minimal shader that should compile without issue.
  VALID_SHADER = <<-SHADER
  #version 330 core
  layout (location = 0) in vec3 aPos;

  void main()
  {
    gl_position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
  }
  SHADER

  # A shader that should not compile.
  INVALID_SHADER = <<-SHADER
  #version 330 core
  asdf;
  SHADER

  describe "#source" do
    it "gets and sets the source code" do
      subject.source = VALID_SHADER
      expect(subject.source).to eq(VALID_SHADER)
    end
  end

  describe "#compile!" do
    it "raises on an invalid shader" do
      subject.source = INVALID_SHADER
      expect { subject.compile! }.to raise_error(Gloop::ShaderCompilationError)
    end
  end
end
