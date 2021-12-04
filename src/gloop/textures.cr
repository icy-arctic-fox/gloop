require "./contextual"
require "./parameters"
require "./texture/bind_target"
require "./texture/target"

module Gloop
  # Reference to all texture binding targets for a context.
  struct Textures
    include Contextual
    include Parameters

    # Defines a method that returns a texture binding target for the specified target.
    #
    # The *target* should be an enum value in `Texture::Target`.
    private macro texture_target(target, name)
      def {{name.id}} : Texture::BindTarget
        Texture::BindTarget.new(@context, Texture::Target::{{target.id}})
      end
    end

    # Retrieves a binding target for 1D textures.
    texture_target Texture1D, :texture_1d

    # Retrieves a binding target for 2D textures.
    texture_target Texture2D, :texture_2d

    # Retrieves a binding target for 3D textures.
    texture_target Texture3D, :texture_3d

    # Retrieves a binding target for 1D texture arrays.
    texture_target Texture1DArray, :texture_1d_array

    # Retrieves a binding target for 2D texture arrays.
    texture_target Texture2DArray, :texture_2d_array

    # Retrieves a binding target for rectangle textures.
    texture_target Rectangle, :rectangle

    # Retrieves a binding target for cube map textures.
    texture_target CubeMap, :cube_map

    # Retrieves a binding target for cube map texture arrays.
    texture_target CubeMapArray, :cube_map_array

    # Retrieves a binding target for buffer textures.
    texture_target Buffer, :buffer

    # Retrieves a binding target for multi-sample 2D textures.
    texture_target MultiSample2D, :multi_sample_2d

    # Retrieves a binding target for multi-sample 2D texture arrays.
    texture_target MultiSample2DArray, :multi_sample_2d_array

    # Retrieves the specified texture binding target.
    def [](target : Texture::Target) : Texture::BindTarget
      Texture::BindTarget.new(@context, target)
    end

    # Retrieves the specified texture binding target.
    @[AlwaysInline]
    def [](target : Symbol) : Texture::BindTarget
      self[Texture::Target.new(target)]
    end

    # Retrieves the active texture unit.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_ACTIVE_TEXTURE`
    # - OpenGL version: 2.0
    @[GLFunction("glGetIntegerv", enum: "GL_ACTIVE_TEXTURE", version: "2.0")]
    parameter(ActiveTexture, unit) do |value|
      value - LibGL::TextureUnit::Texture0.value
    end

    # Sets the active texture unit.
    #
    # - OpenGL function: `glActiveTexture`
    # - OpenGL version: 2.0
    @[GLFunction("glActiveTexture", version: "2.0")]
    def unit=(unit)
      value = LibGL::TextureUnit::Texture0.value + unit
      gl.active_texture(LibGL::TextureUnit.new(value))
    end
  end

  struct Context
    # Retrieves an interface for the texture binding targets for this context.
    def textures : Textures
      Textures.new(self)
    end
  end
end
