require "./shader"

module Gloop
  # Shader processing primitives in the graphics pipeline.
  struct GeometryShader < Shader
    # Indicates this is a geometry shader.
    def self.type
      Shader::Type::Geometry
    end
  end
end
