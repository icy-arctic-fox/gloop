require "./shader"

module Gloop
  # Shader processing rasterization in the graphics pipeline.
  struct FragmentShader < Shader
    # Indicates this is a fragment shader.
    def self.type
      Shader::Type::Fragment
    end
  end
end
