require "opengl"

module Gloop
  # Converts OpenGL error codes to exception instances.
  private struct ErrorFactory
    # Creates an error instance based on a *code* provided by OpenGL.
    # The *code* should come from the `glGetError` function.
    # If the code is `GL_NO_ERROR`, the nil is returned.
    # Otherwise, a subclass corresponding to the error's type is returned.
    # If the *code* is unrecognized, then an error is raised.
    def build(code)
      case LibGL::ErrorCode.new(code.to_i32)
      when LibGL::ErrorCode::NoError                     then nil
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
