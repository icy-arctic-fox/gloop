require "opengl"
require "./error_handling"
require "./vector2"
require "./vector3"
require "./vector4"

module Gloop
  # Reference to a uniform in the currently bound program.
  struct Uniform
    include ErrorHandling

    # Location of the uniform in the current program.
    getter location : Int32

    # Creates the uniform.
    def initialize(@location)
    end

    # Sets the value of the uniform.
    # Assumes the uniform is a single 32-bit floating-point number.
    def value=(value : Float32)
      checked { LibGL.uniform_1f(location, value) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is two 32-bit floating-point numbers.
    def value=(value : Vector2(Float32))
      checked { LibGL.uniform_2f(location, value.x, value.y) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is three 32-bit floating-point numbers.
    def value=(value : Vector3(Float32))
      checked { LibGL.uniform_3f(location, value.x, value.y, value.z) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is four 32-bit floating-point numbers.
    def value=(value : Vector4(Float32))
      checked { LibGL.uniform_4f(location, value.x, value.y, value.z, value.w) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is a single 32-bit signed integer.
    def value=(value : Int32)
      checked { LibGL.uniform_1i(location, value) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is two 32-bit signed integers.
    def value=(value : Vector2(Int32))
      checked { LibGL.uniform_2i(location, value.x, value.y) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is three 32-bit signed integers.
    def value=(value : Vector3(Int32))
      checked { LibGL.uniform_3i(location, value.x, value.y, value.z) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is four 32-bit signed integers.
    def value=(value : Vector4(Int32))
      checked { LibGL.uniform_4i(location, value.x, value.y, value.z, value.w) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is a single 32-bit unsigned integer.
    def value=(value : UInt32)
      checked { LibGL.uniform_1ui(location, value) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is two 32-bit unsigned integers.
    def value=(value : Vector2(UInt32))
      checked { LibGL.uniform_2ui(location, value.x, value.y) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is three 32-bit unsigned integers.
    def value=(value : Vector3(UInt32))
      checked { LibGL.uniform_3ui(location, value.x, value.y, value.z) }
    end

    # Sets the value of the uniform.
    # Assumes the uniform is four 32-bit unsigned integers.
    def value=(value : Vector4(UInt32))
      checked { LibGL.uniform_4ui(location, value.x, value.y, value.z, value.w) }
    end

    # Retrieves the location of the uniform.
    def to_unsafe
      @location
    end
  end
end
