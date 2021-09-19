require "./context"

module Gloop
  # Mix-in indicating that a type requires an OpenGL context.
  # This module defines an initializer that takes a `Context`.
  # It exposes a private `#gl` method for calling OpenGL function in the context.
  module Contextual
    # Creates the instance for the given OpenGL context.
    def initialize(@context : Context)
    end

    # Proxies OpenGL function calls to the context.
    # See: `Context#gl`.
    private def gl
      @context.gl
    end
  end
end
