require "opengl"
require "./int_vertex_attribute_format"
require "./vertex_attribute_pointer"

module Gloop
  # Contains information about a vertex attribute's formatting and its position in a buffer.
  # This descriptor is for integer attributes.
  struct IntVertexAttributePointer < VertexAttributePointer(IntVertexAttributeFormat)
    Format = IntVertexAttributeFormat

    # Creates a vertex attribute format pointer.
    def initialize(size, type, stride, offset)
      format = Format.new(size, type)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with a signed 8-bit type.
    def initialize(size, type : Int8.class, stride, offset)
      format = Format.new(size, type)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with an unsigned 8-bit type.
    def initialize(size, type : UInt8.class, stride, offset)
      format = Format.new(size, type)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with a signed 16-bit type.
    def initialize(size, type : Int16.class, stride, offset)
      format = Format.new(size, type)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with an unsigned 16-bit type.
    def initialize(size, type : UInt16.class, stride, offset)
      format = Format.new(size, type)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with a signed 32-bit type.
    def initialize(size, type : Int32.class, stride, offset)
      format = Format.new(size, type)
      super(format, stride, offset)
    end

    # Creates a vertex attribute format pointer with an unsigned 32-bit type.
    def initialize(size, type : UInt32.class, stride, offset)
      format = Format.new(size, type)
      super(format, stride, offset)
    end

    # Type of data contained in the attribute components.
    def type
      @format.type
    end
  end
end
