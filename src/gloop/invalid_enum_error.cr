require "opengl"
require "./opengl_error"

module Gloop
  class InvalidEnumError < OpenGLError
    # Underlying value that represents the error type.
    def code : LibGL::ErrorCode
      LibGL::ErrorCode::InvalidEnum
    end
  end
end
