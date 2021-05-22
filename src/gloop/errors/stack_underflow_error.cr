require "./opengl_error"

module Gloop
  # An attempt was made to pop from the stack when there was nothing left.
  #
  # This typically indicates a problem with code interacting with OpenGL.
  class StackUnderflowError < OpenGLError
  end
end
