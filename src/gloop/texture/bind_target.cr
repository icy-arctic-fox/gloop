require "../contextual"
require "../image_format"
require "../pixel_format"
require "../pixel_type"
require "./compare_mode"
require "./depth_stencil_mode"
require "./mag_filter"
require "./min_filter"
require "./parameters"
require "./swizzle"
require "./target"
require "./wrap_mode"

module Gloop
  struct Texture < Object
    # Reference to a target that a texture can be bound to.
    # Provides operations for working with textures bound to the target.
    struct BindTarget
      include Contextual
      include Parameters

      # Retrieves the mode of operation for a texture using mixed depth and stencil data.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_DEPTH_STENCIL_TEXTURE_MODE`
      # - OpenGL version: 4.3
      @[GLFunction("glGetTexParameteriv", enum: "GL_DEPTH_STENCIL_TEXTURE_MODE", version: "4.3")]
      texture_target_parameter_getter LibGL::TextureParameterName::DepthStencilTextureMode, depth_stencil_mode : DepthStencilMode

      # Sets the mode of operation for a texture using mixed depth and stencil data.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_DEPTH_STENCIL_TEXTURE_MODE`
      # - OpenGL version: 4.3
      @[GLFunction("glTexParameteri", enum: "GL_DEPTH_STENCIL_TEXTURE_MODE", version: "4.3")]
      texture_target_parameter_setter DepthStencilTextureMode, depth_stencil_mode : DepthStencilMode

      # Retrieves the index of the minimum mipmap level.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_BASE_LEVEL`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_BASE_LEVEL", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureBaseLevel, base_level : Int32

      # Sets the index of the minimum mipmap level.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_BASE_LEVEL`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_BASE_LEVEL", version: "2.0")]
      texture_target_parameter_setter TextureBaseLevel, base_level : Int32

      # Retrieves the maximum mipmap level.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_MAX_LEVEL`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_MAX_LEVEL", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureMaxLevel, max_level : Int32

      # Sets the maximum mipmap level.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_MAX_LEVEL`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_MAX_LEVEL", version: "2.0")]
      texture_target_parameter_setter TextureMaxLevel, max_level : Int32

      # Retrieves the function that should be used when a texture is magnified.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_MAG_FILTER`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_MAG_FILTER", version: "2.0")]
      texture_target_parameter_getter TextureMagFilter, mag_filter : MagFilter

      # Sets the function that should be used when a texture is magnified.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_MAG_FILTER`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_MAG_FILTER", version: "2.0")]
      texture_target_parameter_setter TextureMagFilter, mag_filter : MagFilter

      # Retrieves the function that should be used when a texture is minified.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_MIN_FILTER`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_MIN_FILTER", version: "2.0")]
      texture_target_parameter_getter TextureMinFilter, min_filter : MinFilter

      # Sets the function that should be used when a texture is minified.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_MIN_FILTER`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_MIN_FILTER", version: "2.0")]
      texture_target_parameter_setter TextureMinFilter, min_filter : MinFilter

      # Retrieves the minimum level-of-detail.
      #
      # - OpenGL function: `glGetTexParameterf`
      # - OpenGL enum: `GL_TEXTURE_MIN_LOD`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameterf", enum: "GL_TEXTURE_MIN_LOD", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureMinLOD, min_lod : Float32

      # Sets the minimum level-of-detail.
      #
      # - OpenGL function: `glTexParameterf`
      # - OpenGL enum: `GL_TEXTURE_MIN_LOD`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameterf", enum: "GL_TEXTURE_MIN_LOD", version: "2.0")]
      texture_target_parameter_setter TextureMinLOD, min_lod : Float32

      # Retrieves the maximum level-of-detail.
      #
      # - OpenGL function: `glGetTexParameterf`
      # - OpenGL enum: `GL_TEXTURE_MAX_LOD`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameterf", enum: "GL_TEXTURE_MAX_LOD", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureMaxLOD, max_lod : Float32

      # Sets the maximum level-of-detail.
      #
      # - OpenGL function: `glTexParameterf`
      # - OpenGL enum: `GL_TEXTURE_MAX_LOD`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameterf", enum: "GL_TEXTURE_MAX_LOD", version: "2.0")]
      texture_target_parameter_setter TextureMaxLOD, max_lod : Float32

      # Retrieves the LOD bias.
      #
      # - OpenGL function: `glGetTexParameterf`
      # - OpenGL enum: `GL_TEXTURE_LOD_BIAS`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameterf", enum: "GL_TEXTURE_LOD_BIAS", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureLODBias, lod_bias : Float32

      # Sets the LOD bias.
      #
      # - OpenGL function: `glTexParameterf`
      # - OpenGL enum: `GL_TEXTURE_LOD_BIAS`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameterf", enum: "GL_TEXTURE_LOD_BIAS", version: "2.0")]
      texture_target_parameter_setter TextureLODBias, lod_bias : Float32

      # Retrieves the texture comparison mode.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_COMPARE_MODE`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_COMPARE_MODE", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureCompareMode, compare_mode : CompareMode

      # Sets the texture comparison mode.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_COMPARE_MODE`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_COMPARE_MODE", version: "2.0")]
      texture_target_parameter_setter TextureCompareMode, compare_mode : CompareMode

      # Retrieves the texture comparison function.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_COMPARE_FUNC`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_COMPARE_FUNC", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureCompareFunc, compare_function : DepthFunction

      # Sets the texture comparison function.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_COMPARE_FUNC`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_COMPARE_FUNC", version: "2.0")]
      texture_target_parameter_setter TextureCompareFunc, compare_function : DepthFunction

      # Retrieves the wrapping mode for the s-coordinate.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_WRAP_S`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_WRAP_S", version: "2.0")]
      texture_target_parameter_getter TextureWrapS, wrap_s : WrapMode

      # Sets the wrapping mode for the s-coordinate.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_WRAP_S`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_WRAP_S", version: "2.0")]
      texture_target_parameter_setter TextureWrapS, wrap_s : WrapMode

      # Retrieves the wrapping mode for the t-coordinate.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_WRAP_T`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_WRAP_T", version: "2.0")]
      texture_target_parameter_getter TextureWrapT, wrap_t : WrapMode

      # Sets the wrapping mode for the t-coordinate.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_WRAP_T`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_WRAP_T", version: "2.0")]
      texture_target_parameter_setter TextureWrapT, wrap_t : WrapMode

      # Retrieves the wrapping mode for the r-coordinate.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_WRAP_R`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_WRAP_R", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureWrapR, wrap_r : WrapMode

      # Sets the wrapping mode for the r-coordinate.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_WRAP_R`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_WRAP_R", version: "2.0")]
      texture_target_parameter_setter TextureWrapR, wrap_r : WrapMode

      # Retrieves the red component swizzle.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE_R`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_SWIZZLE_R", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureSwizzleR, swizzle_red : Swizzle

      # Sets the red component swizzle.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE_R`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_SWIZZLE_R", version: "2.0")]
      texture_target_parameter_setter TextureSwizzleR, swizzle_red : Swizzle

      # Retrieves the green component swizzle.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE_G`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_SWIZZLE_G", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureSwizzleG, swizzle_green : Swizzle

      # Sets the green component swizzle.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE_G`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_SWIZZLE_G", version: "2.0")]
      texture_target_parameter_setter TextureSwizzleG, swizzle_green : Swizzle

      # Retrieves the blue component swizzle.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE_B`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_SWIZZLE_B", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureSwizzleB, swizzle_blue : Swizzle

      # Sets the blue component swizzle.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE_B`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_SWIZZLE_B", version: "2.0")]
      texture_target_parameter_setter TextureSwizzleB, swizzle_blue : Swizzle

      # Retrieves the alpha component swizzle.
      #
      # - OpenGL function: `glGetTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE_A`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameteriv", enum: "GL_TEXTURE_SWIZZLE_A", version: "2.0")]
      texture_target_parameter_getter LibGL::TextureParameterName::TextureSwizzleA, swizzle_alpha : Swizzle

      # Sets the alpha component swizzle.
      #
      # - OpenGL function: `glTexParameteri`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE_A`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteri", enum: "GL_TEXTURE_SWIZZLE_A", version: "2.0")]
      texture_target_parameter_setter TextureSwizzleA, swizzle_alpha : Swizzle

      # Retrieves all component swizzle values.
      #
      # Components are returned in the order: red, green, blue, alpha.
      #
      # - OpenGL function: `glGetTexParameterIiv`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE`
      # - OpenGL version: 3.0
      @[GLFunction("glGetTexParameterIiv", enum: "GL_TEXTURE_SWIZZLE", version: "3.0")]
      def swizzle : SwizzleRGBA
        array = uninitialized StaticArray(Int32, 4)
        pname = LibGL::GetTextureParameter.new(LibGL::TextureParameterName::TextureSwizzleRGBA.to_u32)
        gl.get_tex_parameter_i_iv(to_unsafe, pname, array.to_unsafe)
        SwizzleRGBA.new(
          Swizzle.from_value(array.unsafe_fetch(0)),
          Swizzle.from_value(array.unsafe_fetch(1)),
          Swizzle.from_value(array.unsafe_fetch(2)),
          Swizzle.from_value(array.unsafe_fetch(3))
        )
      end

      # Sets all component swizzle values.
      #
      # - OpenGL function: `glTexParameteriv`
      # - OpenGL enum: `GL_TEXTURE_SWIZZLE`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameteriv", enum: "GL_TEXTURE_SWIZZLE", version: "2.0")]
      def swizzle=(swizzle : SwizzleRGBA)
        array = StaticArray[
          swizzle.unsafe_fetch(0).to_i,
          swizzle.unsafe_fetch(1).to_i,
          swizzle.unsafe_fetch(2).to_i,
          swizzle.unsafe_fetch(3).to_i,
        ]
        gl.tex_parameter_iv(to_unsafe, LibGL::TextureParameterName::TextureSwizzleRGBA, array.to_unsafe)
      end

      # Retrieves the border color.
      #
      # - OpenGL function: `glGetTexParameterfv`
      # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameterfv", enum: "GL_TEXTURE_BORDER_COLOR", version: "2.0")]
      def border_color : Color
        components = uninitialized StaticArray(Float32, 4)
        gl.get_tex_parameter_fv(to_unsafe, LibGL::GetTextureParameter::TextureBorderColor, components.to_unsafe)
        Color.new(
          components.unsafe_fetch(0),
          components.unsafe_fetch(1),
          components.unsafe_fetch(2),
          components.unsafe_fetch(3)
        )
      end

      # Retrieves the border color.
      #
      # - OpenGL function: `glGetTexParameterfv`
      # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
      # - OpenGL version: 2.0
      @[GLFunction("glGetTexParameterfv", enum: "GL_TEXTURE_BORDER_COLOR", version: "2.0")]
      def border_color(type : Float32.class) : FloatColorTuple
        components = uninitialized StaticArray(Float32, 4)
        gl.get_tex_parameter_fv(to_unsafe, LibGL::GetTextureParameter::TextureBorderColor, components.to_unsafe)
        {
          components.unsafe_fetch(0),
          components.unsafe_fetch(1),
          components.unsafe_fetch(2),
          components.unsafe_fetch(3),
        }
      end

      # Retrieves the border color.
      #
      # - OpenGL function: `glGetTexParameterIiv`
      # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
      # - OpenGL version: 3.0
      @[GLFunction("glGetTexParameterIiv", enum: "GL_TEXTURE_BORDER_COLOR", version: "3.0")]
      def border_color(type : Int32.class) : Int32ColorTuple
        components = uninitialized StaticArray(Int32, 4)
        gl.get_tex_parameter_i_iv(to_unsafe, LibGL::GetTextureParameter::TextureBorderColor, components.to_unsafe)
        {
          components.unsafe_fetch(0),
          components.unsafe_fetch(1),
          components.unsafe_fetch(2),
          components.unsafe_fetch(3),
        }
      end

      # Retrieves the border color.
      #
      # - OpenGL function: `glGetTexParameterIuiv`
      # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
      # - OpenGL version: 3.0
      @[GLFunction("glGetTexParameterIuiv", enum: "GL_TEXTURE_BORDER_COLOR", version: "3.0")]
      def border_color(type : UInt32.class) : UInt32ColorTuple
        components = uninitialized StaticArray(UInt32, 4)
        gl.get_tex_parameter_i_uiv(to_unsafe, LibGL::GetTextureParameter::TextureBorderColor, components.to_unsafe)
        {
          components.unsafe_fetch(0),
          components.unsafe_fetch(1),
          components.unsafe_fetch(2),
          components.unsafe_fetch(3),
        }
      end

      # Sets the border color.
      #
      # - OpenGL function: `glTexParameterfv`
      # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameterfv", enum: "GL_TEXTURE_BORDER_COLOR", version: "2.0")]
      def border_color=(color : Color)
        components = StaticArray[color.red, color.green, color.blue, color.alpha]
        gl.tex_parameter_fv(to_unsafe, LibGL::TextureParameterName::TextureBorderColor, components.to_unsafe)
      end

      # Sets the border color.
      #
      # - OpenGL function: `glTexParameterfv`
      # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
      # - OpenGL version: 2.0
      @[GLFunction("glTexParameterfv", enum: "GL_TEXTURE_BORDER_COLOR", version: "2.0")]
      def border_color=(color : FloatColorTuple)
        components = StaticArray[
          color.unsafe_fetch(0).to_f32,
          color.unsafe_fetch(1).to_f32,
          color.unsafe_fetch(2).to_f32,
          color.unsafe_fetch(3).to_f32,
        ]
        gl.tex_parameter_fv(to_unsafe, LibGL::TextureParameterName::TextureBorderColor, components.to_unsafe)
      end

      # Sets the border color.
      #
      # - OpenGL function: `glTexParameterIiv`
      # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
      # - OpenGL version: 3.0
      @[GLFunction("glTexParameterIiv", enum: "GL_TEXTURE_BORDER_COLOR", version: "3.0")]
      def border_color=(color : Int32ColorTuple)
        components = StaticArray[
          color.unsafe_fetch(0),
          color.unsafe_fetch(1),
          color.unsafe_fetch(2),
          color.unsafe_fetch(3),
        ]
        gl.tex_parameter_i_iv(to_unsafe, LibGL::TextureParameterName::TextureBorderColor, components.to_unsafe)
      end

      # Sets the border color.
      #
      # - OpenGL function: `glTexParameterIuiv`
      # - OpenGL enum: `GL_TEXTURE_BORDER_COLOR`
      # - OpenGL version: 3.0
      @[GLFunction("glTexParameterIuiv", enum: "GL_TEXTURE_BORDER_COLOR", version: "3.0")]
      def border_color=(color : UInt32ColorTuple)
        components = StaticArray[
          color.unsafe_fetch(0),
          color.unsafe_fetch(1),
          color.unsafe_fetch(2),
          color.unsafe_fetch(3),
        ]
        gl.tex_parameter_i_uiv(to_unsafe, LibGL::TextureParameterName::TextureBorderColor, components.to_unsafe)
      end

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

      # Stores one-dimensional data in the texture.
      #
      # - OpenGL function: `glTexImage1D`
      # - OpenGL version: 2.0
      @[GLFunction("glTexImage1D", version: "2.0")]
      def update_1d(width : Int32,
                    internal_format : ImageFormat, format : PixelFormat, type : PixelType,
                    data : Pointer, level = 0) : Nil
        gl.tex_image_1d(
          to_unsafe,
          level,
          internal_format.to_unsafe,
          width,
          0,
          format.to_unsafe,
          type.to_unsafe,
          data.as(Void*)
        )
      end

      # Stores one-dimensional data in the texture.
      #
      # - OpenGL function: `glTexImage1D`
      # - OpenGL version: 2.0
      @[AlwaysInline]
      @[GLFunction("glTexImage1D", version: "2.0")]
      def update_1d(width : Int32,
                    internal_format : Symbol, format : Symbol, type : Symbol,
                    data : Pointer, level = 0) : Nil
        update_1d(width,
          ImageFormat.new(internal_format),
          PixelFormat.new(format),
          PixelType.new(type),
          data, level)
      end

      # Stores two-dimensional data in the texture.
      #
      # - OpenGL function: `glTexImage2D`
      # - OpenGL version: 2.0
      @[GLFunction("glTexImage2D", version: "2.0")]
      def update_2d(width : Int32, height : Int32,
                    internal_format : ImageFormat, format : PixelFormat, type : PixelType,
                    data : Pointer, level = 0) : Nil
        gl.tex_image_2d(
          to_unsafe,
          level,
          internal_format.to_unsafe,
          width,
          height,
          0,
          format.to_unsafe,
          type.to_unsafe,
          data.as(Void*)
        )
      end

      # Stores two-dimensional data in the texture.
      #
      # - OpenGL function: `glTexImage2D`
      # - OpenGL version: 2.0
      @[AlwaysInline]
      @[GLFunction("glTexImage2D", version: "2.0")]
      def update_2d(width : Int32, height : Int32,
                    internal_format : Symbol, format : Symbol, type : Symbol,
                    data : Pointer, level = 0) : Nil
        update_2d(width, height,
          ImageFormat.new(internal_format),
          PixelFormat.new(format),
          PixelType.new(type),
          data, level)
      end

      # Stores three-dimensional data in the texture.
      #
      # - OpenGL function: `glTexImage3D`
      # - OpenGL version: 2.0
      @[GLFunction("glTexImage3D", version: "2.0")]
      def update_3d(width : Int32, height : Int32, depth : Int32,
                    internal_format : ImageFormat, format : PixelFormat, type : PixelType,
                    data : Pointer, level = 0) : Nil
        gl.tex_image_3d(
          to_unsafe,
          level,
          internal_format.to_unsafe,
          width,
          height,
          depth,
          0,
          format.to_unsafe,
          type.to_unsafe,
          data.as(Void*)
        )
      end

      # Stores three-dimensional data in the texture.
      #
      # - OpenGL function: `glTexImage3D`
      # - OpenGL version: 2.0
      @[AlwaysInline]
      @[GLFunction("glTexImage3D", version: "2.0")]
      def update_3d(width : Int32, height : Int32, depth : Int32,
                    internal_format : Symbol, format : Symbol, type : Symbol,
                    data : Pointer, level = 0) : Nil
        update_3d(width, height, depth,
          ImageFormat.new(internal_format),
          PixelFormat.new(format),
          PixelType.new(type),
          data, level)
      end

      # Generates a mipmap for the texture.
      #
      # - OpenGL function: `glGenerateMipmap`
      # - OpenGL version: 3.0
      @[GLFunction("glGenerateMipmap", version: "3.0")]
      def generate_mipmap : Nil
        gl.generate_mipmap(to_unsafe)
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
