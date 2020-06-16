require "./error_handling"
require "./primitive"

module Gloop
  # Draws primitives.
  abstract struct DrawCommand
    include ErrorHandling

    # Type of primitive to draw.
    getter primitive : Primitive

    # Number of vertices to draw.
    getter count : Int32

    # Creates the draw command.
    def initialize(@primitive, @count)
    end

    # Executes the command.
    abstract def draw
  end
end
