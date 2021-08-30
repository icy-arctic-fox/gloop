require "./attribute"
require "./error_handling"

module Gloop
  # Definition of a vertex attribute.
  # Attributes of this type have 64-bit floating-point values in shaders.
  struct Float64Attribute < Attribute
    include ErrorHandling

    # Types allowed for 64-bit floating-point attributes.
    enum Type : UInt32
      Double  = LibGL::VertexAttribLType::Double
      Float64 = Double

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribLType.new(value)
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
    # The `#type` will be a 64-bit floating-point number.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, type : Float64.class, offset : UInt32)
      initialize(size, :float64, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 64-bit floating-point number.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(size : Int32, offset : UInt32)
      initialize(size, :double, offset)
    end

    # Applies this attribute definition to the specified index of a vertex array.
    def apply(vao, index)
      checked { LibGL.vertex_array_attrib_l_format(vao, index, size, type, offset) }
    end

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    def apply(index)
      checked { LibGL.vertex_attrib_l_format(index, size, type, offset) }
    end
  end
end
