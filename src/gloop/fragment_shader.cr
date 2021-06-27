require "./error_handling"
require "./shader"

module Gloop
  struct FragmentShader < Shader
    extend ErrorHandling

    # Indicates that this is a fragment shader.
    def self.type
      Shader::Type::Fragment
    end
  end
end
