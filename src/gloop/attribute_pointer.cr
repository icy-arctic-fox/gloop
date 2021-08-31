module Gloop
  # Base class for all attribute pointer definitions.
  abstract struct AttributePointer
    # Number of components the attribute contains.
    getter size : Int32

    # Number of bytes between values for this attribute in the buffer.
    # If zero, then the attributes are tightly packed (one after another).
    getter stride : Int32

    # Pointer to the start of attribute data in the vertex buffer.
    getter pointer : Pointer(Void)

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(@size : Int32, @stride : Int32, pointer : Pointer)
      @pointer = pointer.as(Void*)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(@size : Int32, @stride : Int32, offset : UInt64)
      @pointer = Pointer(Void).new(offset)
    end

    # Number of bytes from the start of a vertex buffer to the attribute data.
    def offset
      pointer.address
    end

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    abstract def apply(index)
  end
end
