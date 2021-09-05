require "./errors/*"

# Don't show this file in stack traces.
Exception::CallStack.skip(__FILE__)

module Gloop
  struct Context
    # Retrieves the next error reported by OpenGL.
    #
    # If consecutive errors occur, they are queued up.
    # This method should be checked immediately
    # after interacting with OpenGL when an error might occur.
    #
    # NOTE: Normal usage of the Gloop library doesn't require the consumer to check this method.
    # Gloop will automatically check for errors (unless this feature is disabled).
    def error_code : Error
      code = gl_call get_error
      Error.from_value(code)
    end

    # Retrieves the next error reported by OpenGL.
    # Returns an instance of `OpenGLError`, but does not raise it.
    # If no error occurred, nil is returned.
    #
    # If consecutive errors occur, they are queued up.
    # This method should be checked immediately
    # after interacting with OpenGL when an error might occur.
    #
    # NOTE: Normal usage of the Gloop library doesn't require the consumer to check this method.
    # Gloop will automatically check for errors (unless this feature is disabled).
    def error : OpenGLError?
      translate_error(error_code)
    end

    # Checks if there was an error from OpenGL.
    # If there was an error, it is raised.
    # Othwerise, this method does nothing.
    #
    # If consecutive errors occur, they are queued up.
    # This method should be checked immediately
    # after interacting with OpenGL when an error might occur.
    #
    # NOTE: Normal usage of the Gloop library doesn't require the consumer to check this method.
    # Gloop will automatically check for errors (unless this feature is disabled).
    def error!
      if (e = error)
        raise e
      end
    end

    # Translates an OpenGL error code to its corresponding `OpenGLError` concrete type.
    # Requires the error *code* from OpenGL.
    # Returns nil if there was no error (`Error:None`).
    private def translate_error(code : Error) : OpenGLError?
      case code
      in Error::None                        then nil
      in Error::InvalidEnum                 then InvalidEnumError.new
      in Error::InvalidValue                then InvalidValueError.new
      in Error::InvalidOperation            then InvalidOperationError.new
      in Error::InvalidFramebufferOperation then InvalidFramebufferOperationError.new
      in Error::OutOfMemory                 then OutOfMemoryError.new
      in Error::StackOverflow               then StackOverflowError.new
      in Error::StackUnderflow              then StackUnderflowError.new
      end
    end
  end
end
