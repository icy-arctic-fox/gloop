require "opengl"
require "./opengl_error"

module Gloop
  class StackUnderflowError < OpenGLError
    # Underlying value that represents the error type.
    def code : LibGL::ErrorCode
      LibGL::ErrorCode::StackUnderflow
    end
  end
end
