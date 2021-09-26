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

    # Defines getters and setters for a value associated with the context.
    # The value lives outside of OpenGL, under Gloop's control.
    #
    # Must be used as follows:
    # ```
    # context_storage something : Thing
    # ```
    #
    # Creates the following methods:
    # ```
    # name? : Type?         # Nillable getter that returns nil if not previously set.
    # name : Type           # Getter that raises if not previously set.
    # name = (value : Type) # Setter.
    # ```
    private macro context_storage(declaration)
      {% type = declaration.type.resolve %}
      {% name = declaration.var.id %}

      @@%mutex = Mutex.new
      @@%storage = {} of Context => {{type}}

      def {{name}}? : {{type}}?
        @@%mutex.synchronize { @@%storage[@context]? }
      end

      def {{name}} : {{type}}
        @@%mutex.synchronize { @@%storage[@context] }
      end

      def {{name}}=(value : {{type}})
        @@%mutex.synchronize { @@%storage[@context] = value }
      end
    end
  end
end
