require "opengl"
require "./error_handling"
require "./uniform_type"

module Gloop
  # Information about a usable uniform in a program.
  struct ActiveUniform
    include ErrorHandling

    # Packaged information retrieved in a single call.
    struct Info
      # Size of the uniform variable.
      getter size : Int32

      # Data type of the uniform variable.
      getter type : UniformType

      # Name of the uniform variable.
      getter name : String

      # Creates the wrapper for uniform information.
      protected def initialize(@size, @type, @name)
      end
    end

    # Index of the uniform within its program.
    getter index : Int32

    # Creates a reference to an active uniform.
    protected def initialize(@program : LibGL::UInt, @index : LibGL::Int)
    end

    # Retrieves bulk information about the uniform.
    def info
      capacity = Program.new(@program).max_uniform_name_size
      size = uninitialized Int32
      type = uninitialized UniformType

      # Subtract one from capacity here because Crystal adds a null-terminator for us.
      name = String.new(capacity - 1) do |buffer|
        byte_size = checked do
          LibGL.get_active_uniform(@program, @index, capacity, out length, pointerof(size), pointerof(type), buffer)
          length
        end
        # Don't subtract one here because OpenGL provides the length without the null-terminator.
        {byte_size, 0}
      end

      Info.new(size, type, name)
    end

    # Retrieves the name of the indexed uniform.
    def name
      capacity = Program.new(@program).max_uniform_name_size

      # Subtract one from capacity here because Crystal adds a null-terminator for us.
      String.new(capacity - 1) do |buffer|
        byte_size = checked do
          LibGL.get_active_uniform_name(@program, @index, capacity, out length, buffer)
          length
        end
        # Don't subtract one here because OpenGL provides the length without the null-terminator.
        {byte_size, 0}
      end
    end

    # Retrieves the location of the uniform within the program.
    def location
      @location ||= checked { LibGL.get_uniform_location(@program, name) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is a single 32-bit floating-point number.
    def value=(value : Float32)
      checked { LibGL.program_uniform_1f(@program, location, value) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is two 32-bit floating-point numbers.
    def value=(value : Vector2(Float32))
      checked { LibGL.program_uniform_2f(@program, location, value.x, value.y) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is three 32-bit floating-point numbers.
    def value=(value : Vector3(Float32))
      checked { LibGL.program_uniform_3f(@program, location, value.x, value.y, value.z) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is four 32-bit floating-point numbers.
    def value=(value : Vector4(Float32))
      checked { LibGL.program_uniform_4f(@program, location, value.x, value.y, value.z, value.w) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is a single 32-bit signed integer.
    def value=(value : Int32)
      checked { LibGL.program_uniform_1i(@program, location, value) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is two 32-bit signed integers.
    def value=(value : Vector2(Int32))
      checked { LibGL.program_uniform_2i(@program, location, value.x, value.y) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is three 32-bit signed integers.
    def value=(value : Vector3(Int32))
      checked { LibGL.program_uniform_3i(@program, location, value.x, value.y, value.z) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is four 32-bit signed integers.
    def value=(value : Vector4(Int32))
      checked { LibGL.program_uniform_4i(@program, location, value.x, value.y, value.z, value.w) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is a single 32-bit unsigned integer.
    def value=(value : UInt32)
      checked { LibGL.program_uniform_1ui(@program, location, value) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is two 32-bit unsigned integers.
    def value=(value : Vector2(UInt32))
      checked { LibGL.program_uniform_2ui(@program, location, value.x, value.y) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is three 32-bit unsigned integers.
    def value=(value : Vector3(UInt32))
      checked { LibGL.program_uniform_3ui(@program, location, value.x, value.y, value.z) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is four 32-bit unsigned integers.
    def value=(value : Vector4(UInt32))
      checked { LibGL.program_uniform_4ui(@program, location, value.x, value.y, value.z, value.w) }
    end
  end
end
