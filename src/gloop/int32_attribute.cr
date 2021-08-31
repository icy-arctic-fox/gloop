require "./attribute"
require "./error_handling"

module Gloop
  # Definition of a vertex attribute.
  # Attributes of this type have 32-bit integer values in shaders.
  struct Int32Attribute < Attribute
    include ErrorHandling

    # Types allowed for 32-bit integer attributes.
    enum Type : UInt32
      Byte          = LibGL::VertexAttribIType::Byte
      UnsignedByte  = LibGL::VertexAttribIType::UnsignedByte
      Short         = LibGL::VertexAttribIType::Short
      UnsignedShort = LibGL::VertexAttribIType::UnsignedShort
      Int           = LibGL::VertexAttribIType::Int
      UnsignedInt   = LibGL::VertexAttribIType::UnsignedInt

      Int8   = Byte
      UInt8  = UnsignedByte
      Uint8  = UnsignedByte
      Int16  = Short
      UInt16 = UnsignedShort
      Uint16 = UnsignedShort
      Int32  = Int
      UInt32 = UnsignedInt
      Uint32 = UnsignedInt

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribIType.new(value)
      end
    end

    # Format of data packed into the buffer.
    getter type : Type

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *type* is the format of data of each component.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, @type : Type, offset : UInt32)
      super(size, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 8-bit integer.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Int8.class, offset : UInt32)
      initialize(size, :int8, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 8-bit integer.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : UInt8.class, offset : UInt32)
      initialize(size, :uint8, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 16-bit integer.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Int16.class, offset : UInt32)
      initialize(size, :int16, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 16-bit integer.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : UInt16.class, offset : UInt32)
      initialize(size, :uint16, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 32-bit integer.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Int32.class, offset : UInt32)
      initialize(size, :int32, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 32-bit integer.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : UInt32.class, offset : UInt32)
      initialize(size, :uint32, offset)
    end

    # Applies this attribute definition to the specified index of a vertex array.
    def apply(vao, index)
      checked { LibGL.vertex_array_attrib_i_format(vao, index, size, type, offset) }
    end

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    def apply(index)
      checked { LibGL.vertex_attrib_i_format(index, size, type, offset) }
    end
  end
end
