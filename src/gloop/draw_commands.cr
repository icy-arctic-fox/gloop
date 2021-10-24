require "./capabilities"
require "./index_type"
require "./parameters"
require "./primitive"

module Gloop
  # Methods for drawing primitives.
  #
  # See: `RenderCommands`
  module DrawCommands
    include Capabilities
    include Parameters

    capability PrimitiveRestart, primitive_restart

    capability PrimitiveRestartFixedIndex, primitive_restart_fixed_index, version: "4.3"

    # Value to treat as non-index and starts a new primitive.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_PRIMITIVE_RESTART_INDEX`
    # - OpenGL version: 3.1
    @[GLFunction("glGetIntegerv", enum: "GL_PRIMITIVE_RESTART_INDEX", version: "3.1")]
    parameter PrimitiveRestartIndex, primitive_restart_index : UInt32

    # Specifies the value of an index to signify starting a new primitive.
    #
    # - OpenGL function: `glPrimitiveRestartIndex`
    # - OpenGL version: 3.1
    @[GLFunction("glPrimitiveRestartIndex", version: "3.1")]
    def primitive_restart_index=(index : UInt32)
      gl.primitive_restart_index(index)
    end

    # Draws vertices from the currently bound attribute array buffer(s).
    #
    # - OpenGL function: `glDrawArrays`
    # - OpenGL version: 2.0
    @[GLFunction("glDrawArrays", version: "2.0")]
    def draw_arrays(mode : Primitive, start : Int32, count : Int32) : Nil
      gl.draw_arrays(mode.to_unsafe, start, count)
    end

    # Draws vertices from the currently bound attribute array buffer(s).
    #
    # - OpenGL function: `glDrawArrays`
    # - OpenGL version: 2.0
    @[GLFunction("glDrawArrays", version: "2.0")]
    @[AlwaysInline]
    def draw_arrays(mode : Primitive, range : Range(Int32, Int32)) : Nil
      draw_arrays(mode, range.begin, range.size)
    end

    # Draws vertices based on indices from currently bound attribute and element array buffers.
    #
    # *count* is the number of vertices (indices) to render.
    # The *offset* is a byte offset from the start of the currently bound element array buffer.
    #
    # - OpenGL function: `glDrawElements`
    # - OpenGL version: 2.0
    @[GLFunction("glDrawElements", version: "2.0")]
    def draw_elements(mode : Primitive, count : Int32, type : IndexType, offset : Size) : Nil
      pointer = Pointer(Void).new(offset)
      gl.draw_elements(mode.to_unsafe, count, type.to_unsafe, pointer)
    end

    # Draws vertices based on indices from currently bound attribute and element array buffers.
    #
    # *count* is the number of vertices (indices) to render.
    # The *offset* is a byte offset from the start of the currently bound element array buffer.
    #
    # - OpenGL function: `glDrawElements`
    # - OpenGL version: 2.0
    @[GLFunction("glDrawElements", version: "2.0")]
    @[AlwaysInline]
    def draw_elements(mode : Primitive, count : Int32, type : UInt8.class, offset : Size) : Nil
      draw_elements(mode.to_unsafe, count, :u_int8, offset)
    end

    # Draws vertices based on indices from currently bound attribute and element array buffers.
    #
    # *count* is the number of vertices (indices) to render.
    # The *offset* is a byte offset from the start of the currently bound element array buffer.
    #
    # - OpenGL function: `glDrawElements`
    # - OpenGL version: 2.0
    @[GLFunction("glDrawElements", version: "2.0")]
    @[AlwaysInline]
    def draw_elements(mode : Primitive, count : Int32, type : UInt16.class, offset : Size) : Nil
      draw_elements(mode.to_unsafe, count, :u_int16, offset)
    end

    # Draws vertices based on indices from currently bound attribute and element array buffers.
    #
    # *count* is the number of vertices (indices) to render.
    # The *offset* is a byte offset from the start of the currently bound element array buffer.
    #
    # - OpenGL function: `glDrawElements`
    # - OpenGL version: 2.0
    @[GLFunction("glDrawElements", version: "2.0")]
    @[AlwaysInline]
    def draw_elements(mode : Primitive, count : Int32, type : UInt32.class, offset : Size) : Nil
      draw_elements(mode.to_unsafe, count, :u_int32, offset)
    end
  end
end
