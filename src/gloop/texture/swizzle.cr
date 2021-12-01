module Gloop
  struct Texture < Object
    # Color component or value actually presented to shaders.
    enum Swizzle : Int32
      Zero  = LibGL::TextureSwizzle::Zero
      One   = LibGL::TextureSwizzle::One
      Red   = LibGL::TextureSwizzle::Red
      Green = LibGL::TextureSwizzle::Green
      Blue  = LibGL::TextureSwizzle::Blue
      Alpha = LibGL::TextureSwizzle::Alpha

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::TextureSwizzle.new(value)
      end
    end

    # Swizzle values for all components.
    #
    # Components are ordered: red, green, blue, alpha.
    alias SwizzleRGBA = Tuple(Swizzle, Swizzle, Swizzle, Swizzle)
  end
end
