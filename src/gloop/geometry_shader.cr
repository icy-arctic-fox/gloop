require "opengl"
require "./shader"

module Gloop
  # Shader that operates on collections of vertices.
  struct GeometryShader < Shader
    # The shader's type.
    # Always returns `GeometryShader`
    protected def type : LibGL::ShaderType
      LibGL::ShaderType::GeometryShader
    end
  end
end
