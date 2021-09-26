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

    # Wrapper for fetching strings from OpenGL.
    # Accepts the maximum *capacity* for the string.
    # A new string will be allocated.
    # The buffer (pointer to the string contents), capacity, and length pointer are yielded.
    # The block must call an OpenGL method to retrieve the string and the final length.
    # This method returns the string or nil if *capacity* is less than zero.
    private def string_query(capacity)
      return unless capacity
      return "" if capacity.zero?

      String.new(capacity) do |buffer|
        length = uninitialized Int32
        # Add 1 to capacity because `String.new` adds a byte for the null-terminator.
        yield buffer, capacity + 1, pointerof(length)
        {length, 0}
      end
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
