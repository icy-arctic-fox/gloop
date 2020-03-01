require "opengl"
require "./opengl_error"

module Gloop
  class InvalidValueError < OpenGLError
    # Underlying value that represents the error type.
    def code : LibGL::ErrorCode
      LibGL::ErrorCode::InvalidValue
    end
  end
end