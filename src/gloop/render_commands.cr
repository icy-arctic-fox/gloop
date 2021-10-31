require "./clear_mask"
require "./parameters"

module Gloop
  # Methods for basic rendering.
  #
  # See: `DrawCommands`
  module RenderCommands
    include Parameters

    # Tuple of color components, each value a floating-point number in the range [0, 1].
    alias FloatColorTuple = Tuple(Float32 | Float64, Float32 | Float64, Float32 | Float64, Float32 | Float64)

    # Retrieves the value used to clear the depth buffer.
    #
    # - OpenGL function: `glGetDoublev`
    # - OpenGL enum: `GL_DEPTH_CLEAR_VALUE`
    # - OpenGL version: 2.0
    @[GLFunction("glGetDoublev", enum: "GL_DEPTH_CLEAR_VALUE", version: "2.0")]
    parameter DepthClearValue, clear_depth : Float64

    # Retrieves the value used to clear the stencil buffer.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_STENCIL_CLEAR_VALUE`
    # - OpenGL version: 2.0
    @[GLFunction("glGetIntegerv", enum: "GL_STENCIL_CLEAR_VALUE", version: "2.0")]
    parameter StencilClearValue, clear_stencil : Int32

    # Waits for all previously called GL commands to complete.
    #
    # - OpenGL function: `glFinish`
    # - OpenGL version: 2.0
    @[GLFunction("glFinish", version: "2.0")]
    def finish : Nil
      gl.finish
    end

    # Forces all GL commands to complete before new ones can be issued.
    #
    # - OpenGL function: `glFlush`
    # - OpenGL version: 2.0
    @[GLFunction("glFlush", version: "2.0")]
    def flush : Nil
      gl.flush
    end

    # Clears selected buffers of the output framebuffer.
    #
    # - OpenGL function: `glClear`
    # - OpenGL version: 2.0
    @[GLFunction("glClear", version: "2.0")]
    def clear(mask : ClearMask = :all) : Nil
      gl.clear(mask.to_unsafe)
    end

    # Retrieves the color used to clear the color buffer.
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

    # Sets the value to clear the depth buffer with.
    #
    # See: `#clear`
    #
    # - OpenGL function: `glClearDepth`
    # - OpenGL version: 2.0
    @[GLFunction("glClearDepth", version: "2.0")]
    def clear_depth=(depth : Float64)
      gl.clear_depth(depth)
    end

    # Sets the value to clear the depth buffer with.
    #
    # See: `#clear`
    #
    # - OpenGL function: `glClearDepthf`
    # - OpenGL version: 2.0
    @[GLFunction("glClearDepthf", version: "2.0")]
    def clear_depth=(depth : Float32)
      gl.clear_depth_f(depth)
    end

    # Sets the value to clear the stencil buffer with.
    #
    # See `#clear`
    #
    # - OpenGL function: `glClearStencil`
    # - OpenGL version: 2.0
    @[GLFunction("glClearStencil", value: "2.0")]
    def clear_stencil=(stencil : Int32)
      gl.clear_stencil(stencil)
    end

    # Retrieves the bounding area drawn to the window.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_VIEWPORT`
    # - OpenGL version: 2.0
    @[GLFunction("glGetIntegerv", enum: "GL_VIEWPORT", version: "2.0")]
    def viewport : Rect
      rect = uninitialized Int32[4]
      gl.get_integer_v(LibGL::GetPName::Viewport, rect.to_unsafe)
      Rect.new(rect[0], rect[1], rect[2], rect[3])
    end

    # Sets the bounding area drawn to the window.
    #
    # - OpenGL function: `glViewport`
    # - OpenGL version: 2.0
    @[GLFunction("glViewport", version: "2.0")]
    def viewport=(rect : Rect)
      gl.viewport(rect.x, rect.y, rect.width, rect.height)
    end

    # Sets the bounding area drawn to the window.
    #
    # - OpenGL function: `glViewport`
    # - OpenGL version: 2.0
    @[GLFunction("glViewport", version: "2.0")]
    def viewport=(rect : Tuple(Int32, Int32, Int32, Int32))
      gl.viewport(*rect)
    end
  end
end
