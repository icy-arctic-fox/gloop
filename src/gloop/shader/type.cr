module Gloop
  abstract struct Shader < Object
    # Enum indicating the shader's type.
    enum Type : LibGL::Enum
      Fragment               = LibGL::ShaderType::FragmentShader
      Vertex                 = LibGL::ShaderType::VertexShader
      Geometry               = LibGL::ShaderType::GeometryShader
      TessellationEvaluation = LibGL::ShaderType::TessEvaluationShader
      TessellationControl    = LibGL::ShaderType::TessControlShader
      Compute                = LibGL::ShaderType::ComputeShader

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::ShaderType.new(value)
      end
    end
  end
end
