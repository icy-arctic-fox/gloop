require "opengl"
require "./error_handling"
require "./fragment_shader"
require "./geometry_shader"
require "./vertex_shader"

module Gloop
  # Creates shaders of the correct type from their name.
  struct ShaderFactory
    include ErrorHandling

    # Creates a shader given its name.
    def build(name)
      case (type = type(name))
      when LibGL::ShaderType::FragmentShader then FragmentShader.new(name)
      when LibGL::ShaderType::GeometryShader then GeometryShader.new(name)
      when LibGL::ShaderType::VertexShader   then VertexShader.new(name)
      else
        raise "Unknown shader type - #{type}"
      end
    end

    # Gets a shader's type given its name.
    private def type(name)
      checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::ShaderType, out value)
        LibGL::ShaderType.from_value(value)
      end
    end
  end
end
