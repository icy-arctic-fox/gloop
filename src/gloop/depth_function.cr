module Gloop
  # Comparison method used with depth information.
  enum DepthFunction : UInt32
    Never        = LibGL::DepthFunction::Never
    Less         = LibGL::DepthFunction::Less
    Equal        = LibGL::DepthFunction::Equal
    LessEqual    = LibGL::DepthFunction::LessEqual
    Greater      = LibGL::DepthFunction::Greater
    NotEqual     = LibGL::DepthFunction::NotEqual
    GreaterEqual = LibGL::DepthFunction::GreaterEqual
    Always       = LibGL::DepthFunction::Always

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::DepthFunction.new(value)
    end
  end
end
