module Gloop
  struct Texture < Object
    # Scaling function used when a texture is magnified.
    enum MagFilter : Int32
      Nearest = LibGL::TextureMagFilter::Nearest
      Linear  = LibGL::TextureMagFilter::Linear

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::TextureMagFilter.new(value)
      end
    end
  end
end
