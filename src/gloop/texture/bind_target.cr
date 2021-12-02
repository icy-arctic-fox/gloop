require "../contextual"
require "./parameters"
require "./target"

module Gloop
  struct Texture < Object
    # Reference to a target that a texture can be bound to.
    # Provides operations for working with textures bound to the target.
    struct BindTarget
      include Contextual
      include Parameters

      # Retrieves the context for this target.
      getter context : Context

      # Target this binding refers to.
      getter target : Target

      # Creates a reference to a texture bind target.
      protected def initialize(@context : Context, @target : Target)
      end

      # Retrieves the name of the texture currently bound to this target.
      #
      # Returns a null-object (zero) if no texture is bound.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL version: 2.0
      @[GLFunction("glGetIntegerv", version: "2.0")]
      private def texture_name : Name
        value = uninitialized Int32
        gl.get_integer_v(binding_pname, pointerof(value))
        Name.new!(value)
      end

      # Retrieves the texture currently bound to this target.
      #
      # Returns nil if no texture is bound.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL version: 2.0
      @[GLFunction("glGetIntegerv", version: "2.0")]
      def texture? : Texture?
        name = texture_name
        Texture.new(@context, name) unless name.zero?
      end

      # Retrieves the texture currently bound to this target.
      #
      # Returns `.none` if no texture is bound.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL version: 2.0
      @[GLFunction("glGetIntegerv", version: "2.0")]
      def texture : Texture
        Texture.new(@context, texture_name)
      end

      # Binds a texture to this target.
      #
      # See: `Texture#bind`
      #
      # - OpenGL function: `glBindTexture`
      # - OpenGL version: 2.0
      @[GLFunction("glBindTexture", version: "2.0")]
      def bind(texture : Texture) : Nil
        gl.bind_texture(to_unsafe, texture.to_unsafe)
      end

      # Binds a texture to this target.
      #
      # The previously bound texture (if any) is restored after the block completes.
      #
      # See: `Texture#bind`
      #
      # - OpenGL function: `glBindTexture`
      # - OpenGL version: 2.0
      @[GLFunction("glBindTexture", version: "2.0")]
      def bind(texture : Texture)
        previous = self.texture
        bind(texture)

        begin
          yield
        ensure
          bind(previous)
        end
      end

      # Unbinds any previously bound texture from this target.
      #
      # - OpenGL function: `glBindTexture`
      # - OpenGL version: 2.0
      @[GLFunction("glBindTexture", version: "2.0")]
      def unbind : Nil
        gl.bind_texture(to_unsafe, 0_u32)
      end

      # Returns an OpenGL enum representing this texture binding target.
      def to_unsafe
        @target.to_unsafe
      end

      # Retrieves the corresponding parameter value for `glGet` for this target.
      private def binding_pname # ameba:disable Metrics/CyclomaticComplexity
        case @target
        in Texture::Target::Texture1D          then LibGL::GetPName::TextureBinding1D
        in Texture::Target::Texture2D          then LibGL::GetPName::TextureBinding2D
        in Texture::Target::Texture3D          then LibGL::GetPName::TextureBinding3D
        in Texture::Target::Texture1DArray     then LibGL::GetPName::TextureBinding1DArray
        in Texture::Target::Texture2DArray     then LibGL::GetPName::TextureBinding2DArray
        in Texture::Target::Rectangle          then LibGL::GetPName::TextureBindingRectangle
        in Texture::Target::CubeMap            then LibGL::GetPName::TextureBindingCubeMap
        in Texture::Target::CubeMapArray       then LibGL::GetPName.new(LibGL::TEXTURE_BINDING_CUBE_MAP_ARRAY.to_u32!)
        in Texture::Target::Buffer             then LibGL::GetPName::TextureBindingBuffer
        in Texture::Target::MultiSample2D      then LibGL::GetPName::TextureBinding2DMultisample
        in Texture::Target::MultiSample2DArray then LibGL::GetPName::TextureBinding2DMultisampleArray
        end
      end
    end
  end
end
