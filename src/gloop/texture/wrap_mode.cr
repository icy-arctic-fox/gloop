module Gloop
  struct Texture < Object
    # Method used for texture coordinates outside of the standard range.
    enum WrapMode : Int32
      Repeat            = LibGL::TextureWrapMode::Repeat
      ClampToEdge       = LibGL::TextureWrapMode::ClampToEdge
      ClampToBorder     = LibGL::TextureWrapMode::ClampToBorder
      MirroredRepeat    = LibGL::TextureWrapMode::MirroredRepeat
      MirrorClampToEdge = LibGL::MIRROR_CLAMP_TO_EDGE

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::TextureWrapMode.new(value)
      end
    end
  end
end
