require "../error_handling"
require "../parameters"
require "./binding"

module Gloop
  struct VertexArray < Object
    # Indirect bindings for vertex buffers and attributes.
    struct Bindings
      extend ErrorHandling
      include ErrorHandling
      include Indexable(Binding)
      include Parameters

      # Maximum number of allowed bindings.
      class_parameter MaxVertexAttribBindings, max : Int32

      @size : Int32

      # Maximum number of binding slots allowed.
      getter size

      # Creates the bindings instance.
      def initialize(@vao : UInt32)
        # Size is stored to avoid unecessary lookups to size, which should be static.
        @size = self.class.max
      end

      # Retrieves a binding slot for the vertex array at the specified index.
      def unsafe_fetch(index : Int)
        Binding.new(@vao, index.to_u32)
      end
    end
  end
end
