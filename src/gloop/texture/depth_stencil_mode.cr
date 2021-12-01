module Gloop
  struct Texture < Object
    # Mode of operation for textures with mixed depth and stencil data.
    enum DepthStencilMode : Int32
      StencilIndex   = LibGL::DepthStencilTextureMode::StencilIndex
      DepthComponent = LibGL::DepthStencilTextureMode::DepthComponent

      Stencil = StencilIndex
      Depth   = DepthComponent

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::DepthStencilTextureMode.new(value)
      end
    end
  end
end
