require "./capabilities"
require "./parameters"

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
  end
end
