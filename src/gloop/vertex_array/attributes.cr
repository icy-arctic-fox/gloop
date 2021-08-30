require "../attribute"
require "../error_handling"
require "../parameters"
require "./attribute_index"

module Gloop
  struct VertexArray < Object
    # Interface for accessing attribute information associated with a vertex array.
    struct Attributes
      extend ErrorHandling
      include ErrorHandling
      include Indexable(AttributeIndex)
      include Parameters

      # Maximum number of attribute definitions allowed.
      class_parameter MaxVertexAttribs, max : Int32

      @size : Int32

      # Maximum number of attribute definitions allowed.
      getter size

      # Creates an interface for accessing attributes in a vertex array.
      def initialize(@vao : UInt32)
        # Size is stored to avoid unecessary lookups to size, which should be static.
        @size = self.class.max
      end

      # Retrieves an attribute from the associated vertex array.
      def unsafe_fetch(index : Int)
        AttributeIndex.new(@vao, index.to_u32)
      end

      # Defines an attribute with the specified index.
      # This does not enable or disable the attribute.
      def []=(index : Int, attribute : Attribute)
        attribute.apply(@vao, index)
      end

      # Defines an attribute with the specified index.
      # This does not enable or disable the attribute.
      def []=(index : Int, attribute : AttributeIndex)
        attribute.definition.apply(@vao, index)
      end
    end
  end
end
