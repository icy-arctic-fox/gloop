module Gloop
  struct Texture < Object
    # Types and binding targets of textures.
    enum Target : UInt32
      Texture1D          = LibGL::TextureTarget::Texture1D
      Texture2D          = LibGL::TextureTarget::Texture2D
      Texture3D          = LibGL::TextureTarget::Texture3D
      Texture1DArray     = LibGL::TextureTarget::Texture1DArray
      Texture2DArray     = LibGL::TextureTarget::Texture2DArray
      Rectangle          = LibGL::TextureTarget::TextureRectangle
      CubeMap            = LibGL::TextureTarget::TextureCubeMap
      CubeMapArray       = LibGL::TextureTarget::TextureCubeMapArray
      Buffer             = LibGL::TextureTarget::TextureBuffer
      MultiSample2D      = LibGL::TextureTarget::Texture2DMultisample
      MultiSample2DArray = LibGL::TextureTarget::Texture2DMultisampleArray

      # Creates a texture type from a symbol.
      #
      # This is intended to be used as a workaround for Crystal's limitations and auto-generated names.
      def self.new(value : Symbol) # ameba:disable Metrics/CyclomaticComplexity
        case value
        when :_1d, :"1d", :texture_1d                   then Texture1D
        when :_2d, :"2d", :texture_2d                   then Texture2D
        when :_3d, :"3d", :texture_3d                   then Texture3D
        when :_1d_array, :"1d_array", :texture_1d_array then Texture1DArray
        when :_2d_array, :"2d_array", :texture_2d_array then Texture2DArray
        when :rectangle                                 then Rectangle
        when :cube_map                                  then CubeMap
        when :cube_map_array                            then CubeMapArray
        when :buffer                                    then Buffer
        when :multi_sample_2d                           then MultiSample2D
        when :multi_sample_2d_array                     then MultiSample2DArray
        else                                                 raise ArgumentError.new("Invalid texture type")
        end
      end

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::TextureTarget.new(value)
      end
    end
  end
end
