module Gloop
  struct Shader < Object
    # Enum indicating a shader's type.
    enum Type : LibGL::Enum
      Fragment               = LibGL::ShaderType::FragmentShader
      Vertex                 = LibGL::ShaderType::VertexShader
      Geometry               = LibGL::ShaderType::GeometryShader
      TessellationEvaluation = LibGL::ShaderType::TessEvaluationShader
      TessellationControl    = LibGL::ShaderType::TessControlShader
      Compute                = LibGL::ShaderType::ComputeShader

      TessEval    = TessellationEvaluation
      TessControl = TessellationControl

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::ShaderType.new(value)
      end
    end
  end
end
