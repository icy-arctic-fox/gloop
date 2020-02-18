require "opengl"
require "./shader"

module Gloop
  # Shader that operates on pixels.
  struct FragmentShader < Shader
    # The shader's type.
    # Always returns `FragmentShader`
    def type : LibGL::ShaderType
      LibGL::ShaderType::FragmentShader
    end
  end
end
