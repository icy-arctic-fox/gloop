require "./draw_command"

module Gloop
  struct DrawArraysCommand < DrawCommand
    # Starting index of the vertex to draw.
    getter start : Int32

    # Creates the command.
    def initialize(primitive, @start, count)
      super(primitive, count)
    end

    # Executes the command.
    def draw
      checked { LibGL.draw_arrays(primitive, start, count) }
    end
  end
end
