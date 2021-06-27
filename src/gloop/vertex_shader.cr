require "./shader"

module Gloop
  # Shader processing vertices in the graphics pipeline.
  struct VertexShader < Shader
    # Indicates this is a vertex shader.
    def self.type
      Shader::Type::Vertex
    end
  end
end
