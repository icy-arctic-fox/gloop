require "./shader"

module Gloop
  # Shader for processing arbitrary data.
  struct ComputeShader < Shader
    # Indicates this is a compute shader.
    def self.type
      Shader::Type::Compute
    end
  end
end
