require "opengl"
require "./opengl_error"

module Gloop
  class OutOfMemoryError < OpenGLError
    # Underlying value that represents the error type.
    def code : LibGL::ErrorCode
      LibGL::ErrorCode::OutOfMemory
    end
  end
end
