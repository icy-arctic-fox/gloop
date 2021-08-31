require "./attribute_pointer"
require "./error_handling"

module Gloop
  # Definition of a vertex attribute.
  # Attributes of this type have 32-bit integer values in shaders.
  struct Int32AttributePointer < AttributePointer
    include ErrorHandling

    # Types allowed for 32-bit integer attributes.
    enum Type : UInt32
      Byte          = LibGL::VertexAttribPointerType::Byte
      UnsignedByte  = LibGL::VertexAttribPointerType::UnsignedByte
      Short         = LibGL::VertexAttribPointerType::Short
      UnsignedShort = LibGL::VertexAttribPointerType::UnsignedShort
      Int           = LibGL::VertexAttribPointerType::Int
      UnsignedInt   = LibGL::VertexAttribPointerType::UnsignedInt

      Int8   = Byte
      UInt8  = UnsignedByte
      Int16  = Short
      UInt16 = UnsignedShort
      Int32  = Int
      UInt32 = UnsignedInt

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribPointerType.new(value)
      end
    end

    # Format of data packed into the buffer.
    getter type : Type

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *type* is the format of data of each component.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, @type : Type, stride : Int32, pointer : Pointer)
      super(size, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *type* is the format of data of each component.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, @type : Type, stride : Int32, offset : UInt64)
      super(size, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 8-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int8.class, stride : Int32, pointer : Pointer)
      initialize(size, :int8, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 8-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int8.class, stride : Int32, offset : UInt64)
      initialize(size, :int8, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 8-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt8.class, stride : Int32, pointer : Pointer)
      initialize(size, :uint8, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 8-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt8.class, stride : Int32, offset : UInt64)
      initialize(size, :uint8, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 16-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int16.class, stride : Int32, pointer : Pointer)
      initialize(size, :int16, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 16-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int16.class, stride : Int32, offset : UInt64)
      initialize(size, :int16, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 16-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt16.class, stride : Int32, pointer : Pointer)
      initialize(size, :uint16, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 16-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt16.class, stride : Int32, offset : UInt64)
      initialize(size, :uint16, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 32-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int32.class, stride : Int32, pointer : Pointer)
      initialize(size, :int32, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 32-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int32.class, stride : Int32, offset : UInt64)
      initialize(size, :int32, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 32-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt32.class, stride : Int32, pointer : Pointer)
      initialize(size, :uint32, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 32-bit integer.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt32.class, stride : Int32, offset : UInt64)
      initialize(size, :uint32, stride, offset)
    end

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    def apply(index)
      checked { LibGL.vertex_attrib_i_pointer(index, size, type, stride, pointer) }
    end
  end
end
