require "opengl"
require "./opengl_error"

module Gloop
  class StackOverflowError < OpenGLError
    # Underlying value that represents the error type.
    def code : LibGL::ErrorCode
      LibGL::ErrorCode::StackOverflow
    end
  end
end
