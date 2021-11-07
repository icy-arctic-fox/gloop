require "../contextual"

module Gloop
  struct Program < Object
    # Reference to an active uniform from a program.
    struct UniformLocation
      include Contextual

      # Buffer large enough to safely store a single uniform location.
      # :nodoc:
      alias Float32ValueBuffer = StaticArray(Float32, 16)

      # Buffer large enough to safely store a single uniform location.
      # :nodoc:
      alias Int32ValueBuffer = StaticArray(Int32, 16)

      # Buffer large enough to safely store a single uniform location.
      # :nodoc:
      alias UInt32ValueBuffer = StaticArray(UInt32, 16)

      # Buffer large enough to safely store a single uniform location.
      # :nodoc:
      alias Float64ValueBuffer = StaticArray(Float64, 16)

      # Location of the uniform.
      getter location : Int32

      # Creates a reference to an active uniform.
      def initialize(@context : Context, @name : Name, @location : Int32)
      end

      # Retrieves the value of a uniform.
      #
      # - OpenGL function: `glGetUniformfv`
      # - OpenGL version: 2.0
      @[GLFunction("glGetUniformfv", version: "2.0")]
      def value_as(type : Float32.class) : Float32
        values = uninitialized Float32ValueBuffer
        gl.get_uniform_fv(@name, @location, values.to_unsafe)
        values[0]
      end

      # Retrieves the value of a uniform.
      #
      # - OpenGL function: `glGetUniformdv`
      # - OpenGL version: 4.0
      @[GLFunction("glGetUniformdv", version: "4.0")]
      def value_as(type : Float64.class) : Float64
        values = uninitialized Float64ValueBuffer
        gl.get_uniform_dv(@name, @location, values.to_unsafe)
        values[0]
      end

      # Retrieves the value of a uniform.
      #
      # - OpenGL function: `glGetUniformiv`
      # - OpenGL version: 2.0
      @[GLFunction("glGetUniformiv", version: "2.0")]
      def value_as(type : Int32.class) : Int32
        values = uninitialized Int32ValueBuffer
        gl.get_uniform_iv(@name, @location, values.to_unsafe)
        values[0]
      end

      # Retrieves the value of a uniform.
      #
      # - OpenGL function: `glGetUniformuiv`
      # - OpenGL version: 3.0
      @[GLFunction("glGetUniformuiv", version: "3.0")]
      def value_as(type : UInt32.class) : UInt32
        values = uninitialized UInt32ValueBuffer
        gl.get_uniform_uiv(@name, @location, values.to_unsafe)
        values[0]
      end

      # Sets the value of the uniform.
      #
      # Assumes the uniform is a 32-bit, floating-point number.
      #
      # - OpenGL function: `glProgramUniform1f`
      # - OpenGL version: 4.1
      @[GLFunction("glProgramUniform1f", version: "4.1")]
      def value=(value : Float32)
        gl.program_uniform_1f(@name, @location, value)
      end

      # Sets the value of the uniform.
      #
      # Assumes the uniform is a 64-bit, floating-point number.
      #
      # - OpenGL function: `glProgramUniform1d`
      # - OpenGL version: 4.1
      @[GLFunction("glProgramUniform1d", version: "4.1")]
      def value=(value : Float64)
        gl.program_uniform_1d(@name, @location, value)
      end

      # Sets the value of the uniform.
      #
      # Assumes the uniform is a 32-bit, signed integer.
      #
      # - OpenGL function: `glProgramUniform1i`
      # - OpenGL version: 4.1
      @[GLFunction("glProgramUniform1i", version: "4.1")]
      def value=(value : Int32)
        gl.program_uniform_1i(@name, @location, value)
      end

      # Sets the value of the uniform.
      #
      # Assumes the uniform is a 32-bit, unsigned integer.
      #
      # - OpenGL function: `glProgramUniform1ui`
      # - OpenGL version: 4.1
      @[GLFunction("glProgramUniform1ui", version: "4.1")]
      def value=(value : UInt32)
        gl.program_uniform_1ui(@name, @location, value)
      end
    end
  end
end
