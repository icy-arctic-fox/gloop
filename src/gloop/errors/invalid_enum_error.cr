require "./opengl_error"

module Gloop
  # An enum parameter given to OpenGL was incorrect for that function.
  #
  # This typically indicates a problem in the code calling OpenGL.
  # If this is raised by a Gloop method, this is likely a bug.
  class InvalidEnumError < OpenGLError
  end
end
