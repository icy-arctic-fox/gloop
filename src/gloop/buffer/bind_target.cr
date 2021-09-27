require "../contextual"
require "./target"

module Gloop
  struct Buffer < Object
    # Reference to a target that a buffer can be bound to.
    # Provides operations for working with buffers bound to the target.
    struct BindTarget
      include Contextual

      # Creates a reference to a buffer target for a context.
      def initialize(context : Context, @target : Target)
        initialize(context)
      end

      # Converts to an OpenGL enum.
      def to_unsafe
        @target.to_unsafe
      end
    end
  end
end
