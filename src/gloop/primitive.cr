module Gloop
  # Primitive shape used for drawing verticies.
  enum Primitive : UInt32
    Points                 = LibGL::PrimitiveType::Points
    Lines                  = LibGL::PrimitiveType::Lines
    LineLoop               = LibGL::PrimitiveType::LineLoop
    LineStrip              = LibGL::PrimitiveType::LineStrip
    Triangles              = LibGL::PrimitiveType::Triangles
    TriangleStrip          = LibGL::PrimitiveType::TriangleStrip
    TriangleFan            = LibGL::PrimitiveType::TriangleFan
    LinesAdjacency         = LibGL::PrimitiveType::LinesAdjacency
    LineStripAdjacency     = LibGL::PrimitiveType::LineStripAdjacency
    TrianglesAdjacency     = LibGL::PrimitiveType::TrianglesAdjacency
    TriangleStripAdjacency = LibGL::PrimitiveType::TriangleStripAdjacency
    Patches                = LibGL::PrimitiveType::Patches
    Quads                  = LibGL::PrimitiveType::Quads

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::PrimitiveType.new(value)
    end
  end
end
