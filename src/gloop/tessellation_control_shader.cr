require "./shader"

module Gloop
  # Shader for deciding tesselation amount in the graphics pipeline.
  struct TessellationControlShader < Shader
    # Indicates this is a tessellation control shader.
    def self.type
      Shader::Type::TessellationControl
    end
  end
end
