require "opengl"

module Gloop
  # Simplest type of object that can be drawn.
  enum Primitive : UInt32
    Points = LibGL::PrimitiveType::Points

    Lines = LibGL::PrimitiveType::Lines

    LineLoop = LibGL::PrimitiveType::LineLoop

    LineStrip = LibGL::PrimitiveType::LineStrip

    Triangles = LibGL::PrimitiveType::Triangles

    TriangleStrip = LibGL::PrimitiveType::TriangleStrip

    TriangleFan = LibGL::PrimitiveType::TriangleFan

    TrianglesAdjacency = LibGL::PrimitiveType::TrianglesAdjacency

    TriangleStripAdjacency = LibGL::PrimitiveType::TriangleStripAdjacency

    Patches = LibGL::PrimitiveType::Patches

    Quads = LibGL::PrimitiveType::Quads

    # Converts to the OpenGL equivalent.
    def to_unsafe
      LibGL::PrimitiveType.new(value)
    end
  end
end
