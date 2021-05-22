require "./invalid_operation_error"

module Gloop
  # An operation on a framebuffer is not legal in its current state.
  #
  # This is usually a problem with the code calling OpenGL.
  # An attempt might have been made to read or write to a non-complete framebuffer.
  class InvalidFramebufferOperationError < InvalidOperationError
  end
end
