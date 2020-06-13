require "opengl"
require "./vertex_attribute_format"

module Gloop
  # Description of how a vertex attribute is stored and the data it contains.
  # This descriptor is for integer attributes.
  struct IntVertexAttributeFormat < VertexAttributeFormat
    # Type of data contained in the attribute components.
    getter type : Type

    # Creates a vertex attribute format descriptor.
    def initialize(size, @type, stride, offset)
      super(size, stride, offset)
    end

    # Creates a vertex attribute format descriptor with a signed 8-bit type.
    def initialize(size, type : Int8.class, stride, offset)
      super(size, stride, offset)
      @type = Type::Int8
    end

    # Creates a vertex attribute format descriptor with an unsigned 8-bit type.
    def initialize(size, type : UInt8.class, stride, offset)
      super(size, stride, offset)
      @type = Type::UInt8
    end

    # Creates a vertex attribute format descriptor with a signed 16-bit type.
    def initialize(size, type : Int16.class, stride, offset)
      super(size, stride, offset)
      @type = Type::Int16
    end

    # Creates a vertex attribute format descriptor with an unsigned 16-bit type.
    def initialize(size, type : UInt16.class, stride, offset)
      super(size, stride, offset)
      @type = Type::UInt16
    end

    # Creates a vertex attribute format descriptor with a signed 32-bit type.
    def initialize(size, type : Int32.class, stride, offset)
      super(size, stride, offset)
      @type = Type::Int32
    end

    # Creates a vertex attribute format descriptor with an unsigned 32-bit type.
    def initialize(size, type : UInt32.class, stride, offset)
      super(size, stride, offset)
      @type = Type::UInt32
    end

    # Types of data that can be contained in a floating-point based attribute.
    enum Type : UInt32
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
