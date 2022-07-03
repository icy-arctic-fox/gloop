require "./contextual"

module Gloop
  # Reference to an active uniform in the current program.
  #
  # NOTE: If the active program is changed,
  #   existing references to uniforms will change to the new program,
  #   which may not exist.
  struct UniformLocation
    include Contextual

    # Location of the uniform.
    getter location : Int32

    # Context associated with the uniform location.
    private getter context : Context

    # Creates a reference to an active uniform.
    def initialize(@context : Context, @location : Int32)
    end

    # Sets the value of the uniform.
    #
    # Assumes the uniform is a 32-bit, floating-point number.
    #
    # - OpenGL function: `glUniform1f`
    # - OpenGL version: 2.0
    @[GLFunction("glUniform1f", version: "2.0")]
    def value=(value : Float32)
      gl.uniform_1f(@location, value)
    end

    # Sets the value of the uniform.
    #
    # Assumes the uniform is a 64-bit, floating-point number.
    #
    # - OpenGL function: `glUniform1d`
    # - OpenGL version: 4.0
    @[GLFunction("glUniform1d", version: "4.0")]
    def value=(value : Float64)
      gl.uniform_1d(@location, value)
    end

    # Sets the value of the uniform.
    #
    # Assumes the uniform is a 32-bit, signed integer.
    #
    # - OpenGL function: `glUniform1i`
    # - OpenGL version: 2.0
    @[GLFunction("glUniform1i", version: "2.0")]
    def value=(value : Int32)
      gl.uniform_1i(@location, value)
    end

    # Sets the value of the uniform.
    #
    # Assumes the uniform is a 32-bit, unsigned integer.
    #
    # - OpenGL function: `glUniform1ui`
    # - OpenGL version: 3.0
    @[GLFunction("glUniform1ui", version: "3.0")]
    def value=(value : UInt32)
      gl.uniform_1ui(@location, value)
    end
  end
end
