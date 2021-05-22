require "./opengl_error"

module Gloop
  # An attempt was made to push onto the stack when the maximum stack size has been reached.
  #
  # This typically indicates a very deep call stack or infinite recursion.
  class StackOverflowError < OpenGLError
  end
end
