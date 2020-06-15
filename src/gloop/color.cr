module Gloop
  # Four-component color stored as normalized 32-bit floating-point numbers.
  struct Color
    # Amount of red from 0 to 1.
    getter red : Float32

    # Amount of green from 0 to 1.
    getter green : Float32

    # Amount of blue from 0 to 1.
    getter blue : Float32

    # Amount of alpha (opacity) from 0 to 1.
    getter alpha : Float32

    # Creates the color.
    def initialize(@red, @green, @blue, @alpha)
    end

    # Creates a string representation of the color.
    def to_s(io)
      io << '('
      io << red
      io << ", "
      io << green
      io << ", "
      io << blue
      io << ", "
      io << alpha
      io << ')'
    end
  end
end
