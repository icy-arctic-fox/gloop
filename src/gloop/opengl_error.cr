require "opengl"

module Gloop
  # Common base class for all OpenGL errors.
  abstract class OpenGLError < Exception
    # Underlying value that represents the error type.
    abstract def code : LibGL::ErrorCode
  end
end
