require "opengl"
require "./shader"

module Gloop
  # Shader that operates on vertices.
  struct VertexShader < Shader
    # The shader's type.
    # Always returns `VertexShader`
    def self.type : LibGL::ShaderType
      LibGL::ShaderType::VertexShader
    end

    # The shader's type.
    # Always returns `VertexShader`
    def type : LibGL::ShaderType
      LibGL::ShaderType::VertexShader
    end
  end
end
