require "./attribute_pointer"
require "./error_handling"

module Gloop
  # Definition of a common vertex attribute.
  # Attributes of this type have 32-bit floating-point values in shaders.
  struct Float32AttributePointer < AttributePointer
    include ErrorHandling

    # Types allowed for 32-bit floating-point attributes.
    enum Type : UInt32
      HalfFloat     = LibGL::VertexAttribPointerType::HalfFloat
      Float         = LibGL::VertexAttribPointerType::Float
      Double        = LibGL::VertexAttribPointerType::Double
      Fixed         = LibGL::VertexAttribPointerType::Fixed
      Byte          = LibGL::VertexAttribPointerType::Byte
      UnsignedByte  = LibGL::VertexAttribPointerType::UnsignedByte
      Short         = LibGL::VertexAttribPointerType::Short
      UnsignedShort = LibGL::VertexAttribPointerType::UnsignedShort
      Int           = LibGL::VertexAttribPointerType::Int
      UnsignedInt   = LibGL::VertexAttribPointerType::UnsignedInt

      Float16 = HalfFloat
      Float32 = Float
      Float64 = Double
      Int8    = Byte
      UInt8   = UnsignedByte
      Uint8   = UnsignedByte
      Int16   = Short
      UInt16  = UnsignedShort
      Uint16  = UnsignedShort
      Int32   = Int
      UInt32  = UnsignedInt
      Uint32  = UnsignedInt

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribPointerType.new(value)
      end
    end

    # Format of data packed into the buffer.
    getter type : Type

    # Indicates whether integer types are converted to floats with integer normalization.
    # See: https://www.khronos.org/opengl/wiki/Normalized_Integer
    getter? normalized : Bool

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *type* is the format of data of each component.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, @type : Type, @normalized : Bool, stride : Int32, pointer : Pointer)
      super(size, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *type* is the format of data of each component.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # Lastly, the *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, @type : Type, @normalized : Bool, stride : Int32, offset : UInt64)
      super(size, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 32-bit floating-point number.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Float32.class, stride : Int32, pointer : Pointer)
      initialize(size, :float32, false, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 32-bit floating-point number.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Float32.class, stride : Int32, offset : UInt64)
      initialize(size, :float32, false, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 64-bit floating-point number.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Float64.class, stride : Int32, pointer : Pointer)
      initialize(size, :float64, false, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 64-bit floating-point number.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Float64.class, stride : Int32, offset : UInt64)
      initialize(size, :float64, false, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 8-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int8.class, normalized : Bool, stride : Int32, pointer : Pointer)
      initialize(size, :int8, normalized, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 8-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int8.class, normalized : Bool, stride : Int32, offset : UInt64)
      initialize(size, :int8, normalized, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 8-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt8.class, normalized : Bool, stride : Int32, pointer : Pointer)
      initialize(size, :uint8, normalized, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 8-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt8.class, normalized : Bool, stride : Int32, offset : UInt64)
      initialize(size, :uint8, normalized, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 16-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int16.class, normalized : Bool, stride : Int32, pointer : Pointer)
      initialize(size, :int16, normalized, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 16-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int16.class, normalized : Bool, stride : Int32, offset : UInt64)
      initialize(size, :int16, normalized, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 16-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt16.class, normalized : Bool, stride : Int32, pointer : Pointer)
      initialize(size, :uint16, normalized, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 16-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt16.class, normalized : Bool, stride : Int32, offset : UInt64)
      initialize(size, :uint16, normalized, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 32-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int32.class, normalized : Bool, stride : Int32, pointer : Pointer)
      initialize(size, :int32, normalized, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 32-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Int32.class, normalized : Bool, stride : Int32, offset : UInt64)
      initialize(size, :int32, normalized, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 32-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *pointer* references the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt32.class, normalized : Bool, stride : Int32, pointer : Pointer)
      initialize(size, :uint32, normalized, stride, pointer)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 32-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : UInt32.class, normalized : Bool, stride : Int32, offset : UInt64)
      initialize(size, :uint32, normalized, stride, offset)
    end

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    def apply(index)
      normalized = normalized? ? LibGL::Boolean::True : LibGL::Boolean::False
      checked { LibGL.vertex_attrib_pointer(index, size, type, normalized, stride, pointer) }
    end
  end
end
