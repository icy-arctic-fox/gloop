module Gloop
  struct Texture < Object
    # Method for comparing texture values.
    enum CompareMode : Int32
      None                =    0x0
      CompareRefToTexture = 0x884e
      CompareRToTexture   = 0x884e

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::TextureCompareMode.new(value)
      end
    end
  end
end
