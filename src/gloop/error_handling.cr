require "./errors/*"

# Don't show this file in stack traces.
Exception::CallStack.skip(__FILE__)

module Gloop
  # Mix-in providing error handling features to OpenGL calls.
  # Can be included or extended.
  #
  # Exposes two methods - `#checked` and `#expect_truthy`.
  # Both take a block that should call *one* (and only one) OpenGL function.
  # After the block, the context will be checked for errors.
  # If OpenGL reported an error, an exception corresponding to the error is raised.
  # Otherwise, the value of the block is returned.
  # `#expect_truthy` will only check for errors if the return value from the block is falsey.
  # If the block returns nil, false, or zero, errors will be checked.
  #
  # Error checking is disabled *by default* when building in release mode.
  # To re-enable error checking in release mode, specify the `error_checking` flag.
  # ```shell
  # crystal build --release -Derror_checking ...
  # ```
  private module ErrorHandling
    # Checks for errors from OpenGL after a method has been called.
    #
    # Pass a block to this method that calls *one* OpenGL function.
    # The value of the block will be returned if no error occurred.
    # Otherwise, the error will be translated and raised.
    private def checked
      {% if flag?(:release) && !flag?(:error_checking) %}
        yield
      {% else %}
        yield.tap { error! }
      {% end %}
    end

    # Expects an OpenGL function to return a truthy value.
    #
    # The return value of the function is checked to be not false, nil, or zero.
    # Pass a block to this method that calls *one* OpenGL function.
    # The value of the block will be returned if no error occurred.
    # Otherwise, an error will be raised.
    #
    # An exception will be raised only if an error occurred.
    # The error check will only happen if the block returns non-truthy.
    private def expect_truthy
      {% if flag?(:release) && !flag?(:error_checking) %}
        yield
      {% else %}
        yield.tap do |result|
          error! if !result || (result.responds_to?(:zero?) && result.zero?)
        end
      {% end %}
    end

    # Retrieves the next error reported by OpenGL.
    #
    # If consecutive errors occur, they are queued up.
    # This method should be checked immediately
    # after interacting with OpenGL when an error might occur.
    #
    # NOTE: Normal usage of the Gloop library doesn't require the consumer to check this method.
    # Gloop will automatically check for errors (unless this feature is disabled).
    def error_code : Error
      code = @loader.get_error
      Error.from_value(code)
    end

    # Retrieves the next error reported by OpenGL.
    #
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
    #
    # If there was an error, it is raised.
    # Otherwise, this method does nothing.
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
    #
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
