require "./attribute"
require "./attribute_index"
require "./error_handling"
require "./parameters"

module Gloop
  # Interface for accessing attribute information from the currently bound vertex array.
  module Attributes
    extend self
    include ErrorHandling
    include Parameters

    # Maximum number of attribute definitions allowed.
    parameter MaxVertexAttribs, size : Int32

    # Retrieves an attribute from the bound vertex array.
    def [](index : Int) : AttributeIndex
      AttributeIndex.new(index.to_u32)
    end

    # Defines an attribute with the specified index.
    # This does not enable or disable the attribute.
    def []=(index : Int, attribute : Attribute)
      attribute.apply(index)
    end

    # Defines an attribute with the specified index.
    # This does not enable or disable the attribute.
    def []=(index : Int, attribute : AttributeIndex)
      attribute.definition.apply(index)
    end
  end
end
