require "opengl"
require "./error"

module Gloop
  # Mix-in for handling errors from OpenGL.
  private module ErrorHandling
    extend self

    # Checks for errors from OpenGL after a method has been called.
    # Pass a block to this method that calls *one* OpenGL function.
    # The value of the block will be returned if no error occurred.
    # Otherwise, the error will be translated and raised.
    private def checked
      yield.tap { Gloop.error! }
    end

    # Same as `#checked`, but for static invocations.
    protected def self.static_checked(&block : -> _)
      checked(&block)
    end
  end
end
