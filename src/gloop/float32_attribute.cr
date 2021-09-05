require "./attribute"
require "./error_handling"

module Gloop
  # Definition of a common vertex attribute.
  # Attributes of this type have 32-bit floating-point values in shaders.
  struct Float32Attribute < Attribute
    include ErrorHandling

    # Types allowed for 32-bit floating-point attributes.
    enum Type : LibGL::Enum
      HalfFloat     = LibGL::VertexAttribType::HalfFloat
      Float         = LibGL::VertexAttribType::Float
      Double        = LibGL::VertexAttribType::Double
      Fixed         = LibGL::VertexAttribType::Fixed
      Byte          = LibGL::VertexAttribType::Byte
      UnsignedByte  = LibGL::VertexAttribType::UnsignedByte
      Short         = LibGL::VertexAttribType::Short
      UnsignedShort = LibGL::VertexAttribType::UnsignedShort
      Int           = LibGL::VertexAttribType::Int
      UnsignedInt   = LibGL::VertexAttribType::UnsignedInt

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
        LibGL::VertexAttribType.new(value)
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
    # Lastly, the *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, @type : Type, @normalized : Bool, offset : UInt32)
      super(size, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 32-bit floating-point number.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Float32.class, offset : UInt32)
      initialize(size, :float32, false, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 64-bit floating-point number.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Float64.class, offset : UInt32)
      initialize(size, :float64, false, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 8-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # Lastly, the *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Int8.class, normalized : Bool, offset : UInt32)
      initialize(size, :int8, normalized, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 8-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # Lastly, the *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : UInt8.class, normalized : Bool, offset : UInt32)
      initialize(size, :uint8, normalized, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 16-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # Lastly, the *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Int16.class, normalized : Bool, offset : UInt32)
      initialize(size, :int16, normalized, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 16-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # Lastly, the *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : UInt16.class, normalized : Bool, offset : UInt32)
      initialize(size, :uint16, normalized, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a signed 32-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # Lastly, the *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Int32.class, normalized : Bool, offset : UInt32)
      initialize(size, :int32, normalized, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a unsigned 32-bit integer.
    # When *normalized* is true, integer values are converted to floats in the range [-1, 1].
    # Lastly, the *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : UInt32.class, normalized : Bool, offset : UInt32)
      initialize(size, :uint32, normalized, offset)
    end

    # Applies this attribute definition to the specified index of a vertex array.
    def apply(vao, index)
      normalized = normalized? ? LibGL::Boolean::True : LibGL::Boolean::False
      checked { LibGL.vertex_array_attrib_format(vao, index, size, type, normalized, offset) }
    end

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    def apply(index)
      normalized = normalized? ? LibGL::Boolean::True : LibGL::Boolean::False
      checked { LibGL.vertex_attrib_format(index, size, type, normalized, offset) }
    end
  end
end
