module Gloop
  # Base class for all attribute pointer definitions.
  abstract struct AttributePointer
    {% if flag?(:x86_64) %}
      alias IntPointer = UInt64
    {% else %}
      alias IntPointer = UInt32
    {% end %}

    # Number of components the attribute contains.
    getter size : Int32

    # Number of bytes between values for this attribute in the buffer.
    # If zero, then the attributes are tightly packed (one after another).
    getter stride : Int32

    # Number of bytes from the start of a vertex buffer to the attribute.
    getter offset : IntPointer

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(@size : Int32, @stride : Int32, @offset : IntPointer)
    end

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    abstract def apply(index)

    # Offset value as a pointer.
    private def pointer
      Pointer(IntPointer).new(offset)
    end
  end
end
