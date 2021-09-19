require "./opengl_error"

module Gloop
  # OpenGL command is not legal for the current state.
  #
  # This is usually a problem with the code calling OpenGL.
  class InvalidOperationError < OpenGLError
  end
end
