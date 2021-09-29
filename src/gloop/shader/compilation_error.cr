module Gloop
  struct Shader < Object
    # Error raised when the compilation of a shader fails.
    #
    # See: `Shader#compile!`
    class CompilationError < Exception
    end
  end
end
