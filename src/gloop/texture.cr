require "./color"
require "./depth_function"
require "./object"
require "./texture/*"

module Gloop
  # Collection of one or more images.
  #
  # See: https://www.khronos.org/opengl/wiki/Texture
  struct Texture < Object
    include Parameters

    # Swizzle values for all components.
    #
    # Components are ordered: red, green, blue, alpha.
    alias SwizzleRGBA = Tuple(Swizzle, Swizzle, Swizzle, Swizzle)

    # Tuple of color components, each value a floating-point number in the range [0, 1].
    alias FloatColorTuple = Tuple(Float32 | Float64, Float32 | Float64, Float32 | Float64, Float32 | Float64)

    # Tuple of color components, each value a signed integer.
    alias Int32ColorTuple = Tuple(Int32, Int32, Int32, Int32)

    # Tuple of color components, each value an unsigned integer.
    alias UInt32ColorTuple = Tuple(UInt32, UInt32, UInt32, UInt32)

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

    # Scaling function used when a texture is magnified.
    enum MagFilter : Int32
      Nearest = LibGL::TextureMagFilter::Nearest
      Linear  = LibGL::TextureMagFilter::Linear

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::TextureMagFilter.new(value)
      end
    end

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

    # Retrieves the mode of operation for a texture using mixed depth and stencil data.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_DEPTH_STENCIL_TEXTURE_MODE`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_DEPTH_STENCIL_TEXTURE_MODE", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::DepthStencilTextureMode, depth_stencil_mode : DepthStencilMode

    # Sets the mode of operation for a texture using mixed depth and stencil data.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_DEPTH_STENCIL_TEXTURE_MODE`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_DEPTH_STENCIL_TEXTURE_MODE", version: "4.5")]
    texture_parameter_setter DepthStencilTextureMode, depth_stencil_mode : DepthStencilMode

    # Retrieves the index of the minimum mipmap level.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_BASE_LEVEL`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_BASE_LEVEL", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureBaseLevel, base_level : Int32

    # Sets the index of the minimum mipmap level.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_BASE_LEVEL`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_BASE_LEVEL", version: "4.5")]
    texture_parameter_setter TextureBaseLevel, base_level : Int32

    # Retrieves the maximum mipmap level.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_MAX_LEVEL`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_MAX_LEVEL", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureMaxLevel, max_level : Int32

    # Sets the maximum mipmap level.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_MAX_LEVEL`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_MAX_LEVEL", version: "4.5")]
    texture_parameter_setter TextureMaxLevel, max_level : Int32

    # Retrieves the function that should be used when a texture is magnified.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_MAG_FILTER`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_MAG_FILTER", version: "4.5")]
    texture_parameter_getter TextureMagFilter, mag_filter : MagFilter

    # Sets the function that should be used when a texture is magnified.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_MAG_FILTER`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_MAG_FILTER", version: "4.5")]
    texture_parameter_setter TextureMagFilter, mag_filter : MagFilter

    # Retrieves the function that should be used when a texture is minified.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_MIN_FILTER`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_MIN_FILTER", version: "4.5")]
    texture_parameter_getter TextureMinFilter, min_filter : MinFilter

    # Sets the function that should be used when a texture is minified.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_MIN_FILTER`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_MIN_FILTER", version: "4.5")]
    texture_parameter_setter TextureMinFilter, min_filter : MinFilter

    # Retrieves the minimum level-of-detail.
    #
    # - OpenGL function: `glGetTextureParameterf`
    # - OpenGL enum: `GL_TEXTURE_MIN_LOD`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterf", enum: "GL_TEXTURE_MIN_LOD", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureMinLOD, min_lod : Float32

    # Sets the minimum level-of-detail.
    #
    # - OpenGL function: `glTextureParameterf`
    # - OpenGL enum: `GL_TEXTURE_MIN_LOD`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameterf", enum: "GL_TEXTURE_MIN_LOD", version: "4.5")]
    texture_parameter_setter TextureMinLOD, min_lod : Float32

    # Retrieves the maximum level-of-detail.
    #
    # - OpenGL function: `glGetTextureParameterf`
    # - OpenGL enum: `GL_TEXTURE_MAX_LOD`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterf", enum: "GL_TEXTURE_MAX_LOD", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureMaxLOD, max_lod : Float32

    # Sets the maximum level-of-detail.
    #
    # - OpenGL function: `glTextureParameterf`
    # - OpenGL enum: `GL_TEXTURE_MAX_LOD`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameterf", enum: "GL_TEXTURE_MAX_LOD", version: "4.5")]
    texture_parameter_setter TextureMaxLOD, max_lod : Float32

    # Retrieves the LOD bias.
    #
    # - OpenGL function: `glGetTextureParameterf`
    # - OpenGL enum: `GL_TEXTURE_LOD_BIAS`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterf", enum: "GL_TEXTURE_LOD_BIAS", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureLODBias, lod_bias : Float32

    # Sets the LOD bias.
    #
    # - OpenGL function: `glTextureParameterf`
    # - OpenGL enum: `GL_TEXTURE_LOD_BIAS`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameterf", enum: "GL_TEXTURE_LOD_BIAS", version: "4.5")]
    texture_parameter_setter TextureLODBias, lod_bias : Float32

    # Retrieves the texture comparison mode.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_COMPARE_MODE`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_COMPARE_MODE", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureCompareMode, compare_mode : CompareMode

    # Sets the texture comparison mode.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_COMPARE_MODE`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_COMPARE_MODE", version: "4.5")]
    texture_parameter_setter TextureCompareMode, compare_mode : CompareMode

    # Retrieves the texture comparison function.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_COMPARE_FUNC`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_COMPARE_FUNC", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureCompareFunc, compare_function : DepthFunction

    # Sets the texture comparison function.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_COMPARE_FUNC`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_COMPARE_FUNC", version: "4.5")]
    texture_parameter_setter TextureCompareFunc, compare_function : DepthFunction

    # Retrieves the wrapping mode for the s-coordinate.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_WRAP_S`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_WRAP_S", version: "4.5")]
    texture_parameter_getter TextureWrapS, wrap_s : WrapMode

    # Sets the wrapping mode for the s-coordinate.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_WRAP_S`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_WRAP_S", version: "4.5")]
    texture_parameter_setter TextureWrapS, wrap_s : WrapMode

    # Retrieves the wrapping mode for the t-coordinate.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_WRAP_T`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_WRAP_T", version: "4.5")]
    texture_parameter_getter TextureWrapT, wrap_t : WrapMode

    # Sets the wrapping mode for the t-coordinate.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_WRAP_T`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_WRAP_T", version: "4.5")]
    texture_parameter_setter TextureWrapT, wrap_t : WrapMode

    # Retrieves the wrapping mode for the r-coordinate.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_WRAP_R`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_WRAP_R", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureWrapR, wrap_r : WrapMode

    # Sets the wrapping mode for the r-coordinate.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_WRAP_R`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_WRAP_R", version: "4.5")]
    texture_parameter_setter TextureWrapR, wrap_r : WrapMode

    # Retrieves the red component swizzle.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE_R`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_SWIZZLE_R", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureSwizzleR, swizzle_red : Swizzle

    # Sets the red component swizzle.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE_R`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_SWIZZLE_R", version: "4.5")]
    texture_parameter_setter TextureSwizzleR, swizzle_red : Swizzle

    # Retrieves the green component swizzle.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE_G`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_SWIZZLE_G", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureSwizzleG, swizzle_green : Swizzle

    # Sets the green component swizzle.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE_G`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_SWIZZLE_G", version: "4.5")]
    texture_parameter_setter TextureSwizzleG, swizzle_green : Swizzle

    # Retrieves the blue component swizzle.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE_B`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_SWIZZLE_B", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureSwizzleB, swizzle_blue : Swizzle

    # Sets the blue component swizzle.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE_B`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_SWIZZLE_B", version: "4.5")]
    texture_parameter_setter TextureSwizzleB, swizzle_blue : Swizzle

    # Retrieves the alpha component swizzle.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE_A`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_SWIZZLE_A", version: "4.5")]
    texture_parameter_getter LibGL::TextureParameterName::TextureSwizzleA, swizzle_alpha : Swizzle

    # Sets the alpha component swizzle.
    #
    # - OpenGL function: `glTextureParameteri`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE_A`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteri", enum: "GL_TEXTURE_SWIZZLE_A", version: "4.5")]
    texture_parameter_setter TextureSwizzleA, swizzle_alpha : Swizzle

    # Retrieves all component swizzle values.
    #
    # Components are returned in the order: red, green, blue, alpha.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_SWIZZLE", version: "4.5")]
    def swizzle : SwizzleRGBA
      array = uninitialized StaticArray(Int32, 4)
      pname = LibGL::GetTextureParameter.new(LibGL::TextureParameterName::TextureSwizzleRGBA.to_u32)
      gl.get_texture_parameter_i_iv(name, pname, array.to_unsafe)
      SwizzleRGBA.new(
        Swizzle.from_value(array.unsafe_fetch(0)),
        Swizzle.from_value(array.unsafe_fetch(1)),
        Swizzle.from_value(array.unsafe_fetch(2)),
        Swizzle.from_value(array.unsafe_fetch(3))
      )
    end

    # Sets all component swizzle values.
    #
    # - OpenGL function: `glTextureParameteriv`
    # - OpenGL enum: `GL_TEXTURE_SWIZZLE`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameteriv", enum: "GL_TEXTURE_SWIZZLE", version: "4.5")]
    def swizzle=(swizzle : SwizzleRGBA)
      array = StaticArray[
        swizzle.unsafe_fetch(0).to_i,
        swizzle.unsafe_fetch(1).to_i,
        swizzle.unsafe_fetch(2).to_i,
        swizzle.unsafe_fetch(3).to_i,
      ]
      gl.texture_parameter_iv(name, LibGL::TextureParameterName::TextureSwizzleRGBA, array.to_unsafe)
    end

    # Retrieves the border color.
    #
    # - OpenGL function: `glGetTextureParameterfv`
    # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterfv", enum: "GL_TEXTURE_BORDER_COLOR", version: "4.5")]
    def border_color : Color
      components = uninitialized StaticArray(Float32, 4)
      gl.get_texture_parameter_fv(name, LibGL::GetTextureParameter::TextureBorderColor, components.to_unsafe)
      Color.new(
        components.unsafe_fetch(0),
        components.unsafe_fetch(1),
        components.unsafe_fetch(2),
        components.unsafe_fetch(3)
      )
    end

    # Retrieves the border color.
    #
    # - OpenGL function: `glGetTextureParameterfv`
    # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterfv", enum: "GL_TEXTURE_BORDER_COLOR", version: "4.5")]
    def border_color(type : Float32.class) : FloatColorTuple
      components = uninitialized StaticArray(Float32, 4)
      gl.get_texture_parameter_fv(name, LibGL::GetTextureParameter::TextureBorderColor, components.to_unsafe)
      {
        components.unsafe_fetch(0),
        components.unsafe_fetch(1),
        components.unsafe_fetch(2),
        components.unsafe_fetch(3),
      }
    end

    # Retrieves the border color.
    #
    # - OpenGL function: `glGetTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIiv", enum: "GL_TEXTURE_BORDER_COLOR", version: "4.5")]
    def border_color(type : Int32.class) : Int32ColorTuple
      components = uninitialized StaticArray(Int32, 4)
      gl.get_texture_parameter_i_iv(name, LibGL::GetTextureParameter::TextureBorderColor, components.to_unsafe)
      {
        components.unsafe_fetch(0),
        components.unsafe_fetch(1),
        components.unsafe_fetch(2),
        components.unsafe_fetch(3),
      }
    end

    # Retrieves the border color.
    #
    # - OpenGL function: `glGetTextureParameterIuiv`
    # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
    # - OpenGL version: 4.5
    @[GLFunction("glGetTextureParameterIuiv", enum: "GL_TEXTURE_BORDER_COLOR", version: "4.5")]
    def border_color(type : UInt32.class) : UInt32ColorTuple
      components = uninitialized StaticArray(UInt32, 4)
      gl.get_texture_parameter_i_uiv(name, LibGL::GetTextureParameter::TextureBorderColor, components.to_unsafe)
      {
        components.unsafe_fetch(0),
        components.unsafe_fetch(1),
        components.unsafe_fetch(2),
        components.unsafe_fetch(3),
      }
    end

    # Sets the border color.
    #
    # - OpenGL function: `glTextureParameterfv`
    # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameterfv", enum: "GL_TEXTURE_BORDER_COLOR", version: "4.5")]
    def border_color=(color : Color)
      components = StaticArray[color.red, color.green, color.blue, color.alpha]
      gl.texture_parameter_fv(name, LibGL::TextureParameterName::TextureBorderColor, components.to_unsafe)
    end

    # Sets the border color.
    #
    # - OpenGL function: `glTextureParameterfv`
    # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameterfv", enum: "GL_TEXTURE_BORDER_COLOR", version: "4.5")]
    def border_color=(color : FloatColorTuple)
      components = StaticArray[
        color.unsafe_fetch(0).to_f32,
        color.unsafe_fetch(1).to_f32,
        color.unsafe_fetch(2).to_f32,
        color.unsafe_fetch(3).to_f32
      ]
      gl.texture_parameter_fv(name, LibGL::TextureParameterName::TextureBorderColor, components.to_unsafe)
    end

    # Sets the border color.
    #
    # - OpenGL function: `glTextureParameterIiv`
    # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameterIiv", enum: "GL_TEXTURE_BORDER_COLOR", version: "4.5")]
    def border_color=(color : Int32ColorTuple)
      components = StaticArray[
        color.unsafe_fetch(0),
        color.unsafe_fetch(1),
        color.unsafe_fetch(2),
        color.unsafe_fetch(3)
      ]
      gl.texture_parameter_i_iv(name, LibGL::TextureParameterName::TextureBorderColor, components.to_unsafe)
    end

    # Sets the border color.
    #
    # - OpenGL function: `glTextureParameterIuiv`
    # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
    # - OpenGL version: 4.5
    @[GLFunction("glTextureParameterIuiv", enum: "GL_TEXTURE_BORDER_COLOR", version: "4.5")]
    def border_color=(color : UInt32ColorTuple)
      components = StaticArray[
        color.unsafe_fetch(0),
        color.unsafe_fetch(1),
        color.unsafe_fetch(2),
        color.unsafe_fetch(3)
      ]
      gl.texture_parameter_i_uiv(name, LibGL::TextureParameterName::TextureBorderColor, components.to_unsafe)
    end

    # Generates a new texture.
    #
    # The texture isn't assigned a type or resources until it is bound.
    #
    # See: `.create`
    #
    # - OpenGL function: `glGenTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glGenTextures", version: "2.0")]
    def self.generate(context) : self
      name = uninitialized Name
      context.gl.gen_textures(1, pointerof(name))
      new(context, name)
    end

    # Creates a new texture of the specified type.
    #
    # - OpenGL function: `glCreateTextures`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateTextures", version: "4.5")]
    def self.create(context, type : Target) : self
      name = uninitialized Name
      context.gl.create_textures(type.to_unsafe, 1, pointerof(name))
      new(context, name)
    end

    # Creates a new texture of the specified type.
    #
    # - OpenGL function: `glCreateTextures`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateTextures", version: "4.5")]
    @[AlwaysInline]
    def self.create(context, type : Symbol) : self
      create(context, Target.new(type))
    end

    # Deletes this texture.
    #
    # - OpenGL function: `glDeleteTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteTextures", version: "2.0")]
    def delete
      gl.delete_textures(1, pointerof(@name))
    end

    # Deletes multiple textures.
    #
    # - OpenGL function: `glDeleteTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteTextures", version: "2.0")]
    def self.delete(textures : Enumerable(self)) : Nil
      super do |context, names|
        context.gl.delete_textures(names.size, names.to_unsafe)
      end
    end

    # Checks if the texture is known by OpenGL.
    #
    # - OpenGL function: `glIsTexture`
    # - OpenGL version: 2.0
    @[GLFunction("glIsTexture", version: "2.0")]
    def exists?
      value = gl.is_texture(to_unsafe)
      !value.false?
    end

    # Indicates that this is a texture object.
    def object_type
      Object::Type::Texture
    end

    # Binds this texture to a specified target.
    #
    # - OpenGL function: `glBindTexture`
    # - OpenGL version: 2.0
    @[GLFunction("glBindTexture", version: "2.0")]
    def bind(target : Target) : Nil
      gl.bind_texture(target.to_unsafe, @name)
    end

    # Binds this texture to a specified target.
    #
    # - OpenGL function: `glBindTexture`
    # - OpenGL version: 2.0
    @[GLFunction("glBindTexture", version: "2.0")]
    @[AlwaysInline]
    def bind(target : Symbol) : Nil
      bind(Target.new(target))
    end
  end

  struct Context
    # Generates a new texture.
    #
    # See: `Texture.generate`
    def generate_texture : Texture
      Texture.generate(self)
    end

    # Generates multiple textures.
    #
    # See: `Texture.generate`
    def generate_textures(count : Int) : TextureList
      TextureList.generate(self, count)
    end

    # Creates a new texture of the specified type.
    #
    # See: `Texture.create`
    def create_texture(type : Texture::Target) : Texture
      Texture.create(self, type)
    end

    # Creates a new texture of the specified type.
    #
    # See: `Texture.create`
    def create_texture(type : Symbol) : Texture
      Texture.create(self, type)
    end

    # Creates multiple textures of the specified type.
    #
    # See: `Texture.create`
    def create_textures(type : Texture::Target, count : Int) : TextureList
      TextureList.create(self, type, count)
    end

    # Creates multiple textures of the specified type.
    #
    # See: `Texture.create`
    def create_textures(type : Symbol, count : Int) : TextureList
      TextureList.create(self, type, count)
    end
  end

  # Collection of textures belonging to the same context.
  struct TextureList < ObjectList(Texture)
    # Generates multiple textures.
    #
    # The textures aren't assigned a type or resources until they are bound.
    #
    # See: `#create`
    #
    # - OpenGL function: `glGenTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glGenTextures", version: "2.0")]
    def self.generate(context, count : Int) : self
      new(context, count) do |names|
        context.gl.gen_textures(count, names)
      end
    end

    # Creates multiple textures of the specified type.
    #
    # - OpenGL function: `glCreateTextures`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateTextures", version: "4.5")]
    def self.create(context, type : Texture::Target, count : Int) : self
      new(context, count) do |names|
        context.gl.create_textures(type.to_unsafe, count, names)
      end
    end

    # Creates multiple textures of the specified type.
    #
    # - OpenGL function: `glCreateTextures`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateTextures", version: "4.5")]
    @[AlwaysInline]
    def self.create(context, type : Symbol, count : Int) : self
      create(context, Texture::Target.new(type), count)
    end

    # Deletes all textures in the list.
    #
    # - OpenGL function: `glDeleteTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteTextures", version: "2.0")]
    def delete : Nil
      gl.delete_textures(size, to_unsafe)
    end
  end
end
