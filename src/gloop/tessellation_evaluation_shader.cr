require "./shader"

module Gloop
  # Shader for computing tesselated vertices in the graphics pipeline.
  struct TessellationEvaluationShader < Shader
    # Indicates this is a tessellation evaluation shader.
    def self.type
      Shader::Type::TessellationEvaluation
    end
  end
end
