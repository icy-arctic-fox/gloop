require "opengl"
require "./opengl_error"

module Gloop
  class InvalidFramebufferOperationError < OpenGLError
    # Underlying value that represents the error type.
    def code : LibGL::ErrorCode
      LibGL::ErrorCode::InvalidFramebufferOperation
    end
  end
end
