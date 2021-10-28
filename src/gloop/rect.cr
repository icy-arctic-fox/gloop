module Gloop
  # Two-dimensional, rectangular region.
  struct Rect
    # X-coordinate of a corner of the rectangular region.
    getter x : Int32

    # Y-coordinate of a corner of the rectangular region.
    getter y : Int32

    # Width of the rectangular region.
    getter width : Int32

    # Height of the rectangular region.
    getter height : Int32

    # Creates a rectangular region.
    def initialize(@x : Int32, @y : Int32, @width : Int32, @height : Int32)
    end
  end
end
