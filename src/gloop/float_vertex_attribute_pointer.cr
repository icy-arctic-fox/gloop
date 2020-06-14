require "opengl"
require "./float_vertex_attribute_format"
require "./vertex_attribute_pointer"

module Gloop
  # Contains information about a vertex attribute's formatting and its position in a buffer.
  # This descriptor is for floating-point attributes.
  struct FloatVertexAttributePointer < VertexAttributePointer(FloatVertexAttributeFormat)
    # Creates a vertex attribute format pointer.
    def initialize(size, type, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with a 32-bit floating-point type.
    def initialize(size, type : Float32.class, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with a 64-bit floating-point type.
    def initialize(size, type : Float64.class, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with a signed 8-bit type.
    def initialize(size, type : Int8.class, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with an unsigned 8-bit type.
    def initialize(size, type : UInt8.class, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with a signed 16-bit type.
    def initialize(size, type : Int16.class, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with an unsigned 16-bit type.
    def initialize(size, type : UInt16.class, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with a signed 32-bit type.
    def initialize(size, type : Int32.class, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with an unsigned 32-bit type.
    def initialize(size, type : UInt32.class, normalized, stride, offset)
      format = FloatVertexAttributeFormat.new(size, type, normalized)
      super(format, stride, offset)
    end

    # Type of data contained in the attribute components.
    def type
      @format.type
    end

    # Indicates whether values stored as integers are mapped to the range [-1, 1] or [0, 1]
    # for signed and unsigned values respectively.
    def normalized?
      @format.normalized?
    end
  end
end
