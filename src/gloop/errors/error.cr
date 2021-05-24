module Gloop
  # Error codes for known OpenGL errors.
  enum Error : LibGL::Enum
    # No error reported by OpenGL.
    None = LibGL::ErrorCode::NoError

    # An enum parameter given to OpenGL was incorrect for that function.
    #
    # This typically indicates a problem in the code calling OpenGL.
    # If this is raised by a Gloop method, this is likely a bug.
    InvalidEnum = LibGL::ErrorCode::InvalidEnum

    # A value given to OpenGL was incorrect for that function.
    #
    # This is usually a problem with the code calling OpenGL.
    InvalidValue = LibGL::ErrorCode::InvalidValue

    # OpenGL command is not legal for the current state.
    #
    # This is usually a problem with the code calling OpenGL.
    InvalidOperation = LibGL::ErrorCode::InvalidOperation

    # An operation on a framebuffer is not legal in its current state.
    #
    # This is usually a problem with the code calling OpenGL.
    # An attempt might have been made to read or write to a non-complete framebuffer.
    InvalidFramebufferOperation = LibGL::ErrorCode::InvalidFramebufferOperation

    # OpenGL could not allocate more memory.
    #
    # This could be RAM or VRAM.
    # Virtually any OpenGL function could report this error.
    # OpenGL will be in an undefined state when this occurs.
    OutOfMemory = LibGL::ErrorCode::OutOfMemory

    # An attempt was made to push onto the stack when the maximum stack size has been reached.
    #
    # This typically indicates a very deep call stack or infinite recursion.
    StackOverflow = LibGL::ErrorCode::StackOverflow

    # An attempt was made to pop from the stack when there was nothing left.
    #
    # This typically indicates a problem with code interacting with OpenGL.
    StackUnderflow = LibGL::ErrorCode::StackUnderflow

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::ErrorCode.new(value)
    end
  end
end
