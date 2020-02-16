require "opengl"
require "./opengl_error"

module Gloop
  class InvalidOperationError < OpenGLError
    # Underlying value that represents the error type.
    def code : LibGL::ErrorCode
      LibGL::ErrorCode::InvalidOperation
    end
  end
end
