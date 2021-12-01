module Gloop
  struct Texture < Object
    # Scaling function used when a texture is minified.
    enum MinFilter : Int32
      Nearest              = LibGL::TextureMinFilter::Nearest
      Linear               = LibGL::TextureMinFilter::Linear
      NearestMipmapNearest = LibGL::TextureMinFilter::NearestMipmapNearest
      LinearMipmapNearest  = LibGL::TextureMinFilter::LinearMipmapNearest
      NearestMipmapLinear  = LibGL::TextureMinFilter::NearestMipmapLinear
      LinearMipmapLinear   = LibGL::TextureMinFilter::LinearMipmapLinear

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::TextureMinFilter.new(value)
      end
    end
  end
end
