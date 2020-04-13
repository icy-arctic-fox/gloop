require "./error"

module Gloop
  # Mix-in for handling errors from OpenGL.
  #
  # Error checking is disabled on release builds unless the `error_checking` flag is specified.
  private module ErrorHandling
    extend self

    # Checks for errors from OpenGL after a method has been called.
    # Pass a block to this method that calls *one* OpenGL function.
    # The value of the block will be returned if no error occurred.
    # Otherwise, the error will be translated and raised.
    private def checked
      {% if flag?(:release) && !flag?(:error_checking) %}
        yield
      {% else %}
        yield.tap { Gloop.error! }
      {% end %}
    end

    # Expects an OpenGL function to return a truthy value.
    # The return value of the function is checked
    # to be not false, nil, or integer false (zero).
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
          Gloop.error! if !result ||
                          (result.responds_to?(:zero?) && result.zero?)
        end
      {% end %}
    end

    # Same as `#checked`, but for static invocations.
    protected def self.static_checked(&block : -> _)
      checked(&block)
    end

    # Same as `#expect_truthy`, but for static invocations.
    protected def self.static_expect_truthy(&block : -> _)
      expect_truthy(&block)
    end
  end
end
