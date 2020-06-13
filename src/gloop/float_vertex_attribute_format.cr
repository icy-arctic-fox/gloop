require "opengl"
require "./vertex_attribute_format"

module Gloop
  # Description of how a vertex attribute is stored and the data it contains.
  # This descriptor is for floating-point attributes.
  struct FloatVertexAttributeFormat < VertexAttributeFormat
    # Type of data contained in the attribute components.
    getter type : Type

    # Indicates whether values stored as integers are mapped to the range [-1, 1] or [0, 1]
    # for signed and unsigned values respectively.
    getter? normalized : Bool

    # Creates a vertex attribute format descriptor.
    def initialize(size, @type, @normalized)
      super(size)
    end

    # Creates a vertex attribute format descriptor with a 32-bit floating-point type.
    def initialize(size, type : Float32.class, @normalized)
      super(size)
      @type = Type::Float32
    end

    # Creates a vertex attribute format descriptor with a 64-bit floating-point type.
    def initialize(size, type : Float64.class, @normalized)
      super(size)
      @type = Type::Float64
    end

    # Creates a vertex attribute format descriptor with a signed 8-bit type.
    def initialize(size, type : Int8.class, @normalized)
      super(size)
      @type = Type::Int8
    end

    # Creates a vertex attribute format descriptor with an unsigned 8-bit type.
    def initialize(size, type : UInt8.class, @normalized)
      super(size)
      @type = Type::UInt8
    end

    # Creates a vertex attribute format descriptor with a signed 16-bit type.
    def initialize(size, type : Int16.class, @normalized)
      super(size)
      @type = Type::Int16
    end

    # Creates a vertex attribute format descriptor with an unsigned 16-bit type.
    def initialize(size, type : UInt16.class, @normalized)
      super(size)
      @type = Type::UInt16
    end

    # Creates a vertex attribute format descriptor with a signed 32-bit type.
    def initialize(size, type : Int32.class, @normalized)
      super(size)
      @type = Type::Int32
    end

    # Creates a vertex attribute format descriptor with an unsigned 32-bit type.
    def initialize(size, type : UInt32.class, @normalized)
      super(size)
      @type = Type::UInt32
    end

    # Types of data that can be contained in a floating-point based attribute.
    enum Type : UInt32
      # 16-bit half-precision floating-point value.
      Float16 = LibGL::VertexAttribPointerType::HalfFloat

      # 32-bit single-precision floating-point value.
      Float32 = LibGL::VertexAttribPointerType::Float

      # 64-bit double-precision floating-point value.
      Float64 = LibGL::VertexAttribPointerType::Double

      # 16.16-bit fixed-point two's complement value.
      Fixed = LibGL::VertexAttribPointerType::Fixed

      # Signed 8-bit two's complement value.
      Int8 = LibGL::VertexAttribPointerType::Byte

      # Unsigned 8-bit value.
      UInt8 = LibGL::VertexAttribPointerType::UnsignedByte

      # Signed 16-bit two's complement value.
      Int16 = LibGL::VertexAttribPointerType::Short

      # Unsigned 16-bit value.
      UInt16 = LibGL::VertexAttribPointerType::UnsignedShort

      # Signed 32-bit two's complement value.
      Int32 = LibGL::VertexAttribPointerType::Int

      # Unsigned 32-bit value.
      UInt32 = LibGL::VertexAttribPointerType::UnsignedInt

      # Returns the OpenGL enum type.
      def to_unsafe
        LibGL::VertexAttribPointerType.new(value)
      end
    end
  end
end
