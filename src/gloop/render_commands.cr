require "./clear_mask"

module Gloop
  # Methods for basic rendering.
  #
  # See: `DrawingCommands`
  module RenderCommands
    # Tuple of color components, each value a floating-point number in the range [0, 1].
    alias FloatColorTuple = Tuple(Float32 | Float64, Float32 | Float64, Float32 | Float64, Float32 | Float64)

    # Clears selected buffers of the output framebuffer.
    #
    # - OpenGL function: `glClear`
    # - OpenGL version: 2.0
    @[GLFunction("glClear", version: "2.0")]
    def clear(mask : ClearMask = :all) : Nil
      gl.clear(mask.to_unsafe)
    end

    # Retrieves thte color used to clear the color buffer.
    #
    # - OpenGL function: `glGetFloatv`
    # - OpenGL enum: `GL_COLOR_CLEAR_VALUE`
    # - OpenGL version: 2.0
    @[GLFunction("glGetFloatv", enum: "GL_COLOR_CLEAR_VALUE", version: "2.0")]
    def clear_color : Color
      components = uninitialized Float32[4]
      gl.get_float_v(LibGL::GetPName::ColorClearValue, components.to_unsafe)
      Color.new(components[0], components[1], components[2], components[3])
    end

    # Sets the color to clear the color buffer with.
    #
    # See: `#clear`
    #
    # - OpenGL function: `glCearColor`
    # - OpenGL version: 2.0
    @[GLFunction("glClearColor", version: "2.0")]
    def clear_color=(color : Color)
      gl.clear_color(color.red, color.green, color.blue, color.alpha)
    end

    # Sets the color to clear the color buffer with.
    #
    # See: `#clear`
    #
    # - OpenGL function: `glCearColor`
    # - OpenGL version: 2.0
    @[GLFunction("glClearColor", version: "2.0")]
    def clear_color=(color : FloatColorTuple)
      floats = color.map(&.to_f32)
      gl.clear_color(*floats)
    end
  end
end
