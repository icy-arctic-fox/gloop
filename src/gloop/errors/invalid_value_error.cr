require "./opengl_error"

module Gloop
  # A value given to OpenGL was incorrect for that function.
  #
  # This is usually a problem with the code calling OpenGL.
  class InvalidValueError < OpenGLError
  end
end
