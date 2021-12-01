module Gloop
  # Tuple of color components, each value a floating-point number in the range [0, 1].
  alias FloatColorTuple = Tuple(Float32 | Float64, Float32 | Float64, Float32 | Float64, Float32 | Float64)

  # Tuple of color components, each value a signed integer.
  alias Int32ColorTuple = Tuple(Int32, Int32, Int32, Int32)

  # Tuple of color components, each value an unsigned integer.
  alias UInt32ColorTuple = Tuple(UInt32, UInt32, UInt32, UInt32)

  # Standard four-component color value.
  #
  # Stores four color components - red, green, blue, and alpha.
  # Each component is represented as a 32-bit floating-point number.
  # Component values should be in the range [0, 1], but may extend past it.
  struct Color
    # Amount of the red component.
    getter red : Float32 = 0

    # Amount of the green component.
    getter green : Float32 = 0

    # Amount of the blue component.
    getter blue : Float32 = 0

    # Amount of the alpha component.
    getter alpha : Float32 = 0

    # Creates the color with all components defined.
    def initialize(@red : Float32, @green : Float32, @blue : Float32, @alpha : Float32)
    end
  end
end
