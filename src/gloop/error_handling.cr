require "opengl"

module Gloop
  # Mix-in for handling errors from OpenGL.
  private module ErrorHandling
    extend self

    # Checks if an error occurred in OpenGL
    # and raises an exception if one did.
    private def check_error
      code = LibGL.get_error
      if code != LibGL::ErrorCode::NoError
        raise translate_error(code)
      end
    end

    # Checks for errors from OpenGL after a method has been called.
    # Pass a block to this method that calls *one* OpenGL function.
    # The value of the block will be returned if no error occurred.
    # Otherwise, the error will be translated and raised.
    private def checked
      yield.tap { check_error }
    end

    # Same as `#checked`, but for static invocations.
    protected def self.static_checked(&block : -> _)
      checked(&block)
    end

    # Creates an error from the given code.
    # The *code* indicates which type of error to create.
    private def translate_error(code)
      case code
      when LibGL::ErrorCode::InvalidEnum                 then InvalidEnumError.new
      when LibGL::ErrorCode::InvalidValue                then InvalidValueError.new
      when LibGL::ErrorCode::InvalidOperation            then InvalidOperationError.new
      when LibGL::ErrorCode::OutOfMemory                 then OutOfMemoryError.new
      when LibGL::ErrorCode::InvalidFramebufferOperation then InvalidFramebufferOperationError.new
      when LibGL::ErrorCode::StackUnderflow              then StackUnderflowError.new
      when LibGL::ErrorCode::StackOverflow               then StackOverflowError.new
      else
        raise "Unrecognized error code from OpenGL - #{code}"
      end
    end
  end
end
