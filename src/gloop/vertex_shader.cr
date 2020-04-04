require "opengl"
require "./shader"

module Gloop
  # Shader that operates on vertices.
  struct VertexShader < Shader
    # The shader's type.
    # Always returns `VertexShader`
    protected def type : LibGL::ShaderType
      LibGL::ShaderType::VertexShader
    end
  end
end
