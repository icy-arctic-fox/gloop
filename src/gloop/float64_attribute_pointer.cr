require "./attribute_pointer"
require "./error_handling"

module Gloop
  # Definition of a vertex attribute.
  # Attributes of this type have 64-bit floating-point values in shaders.
  struct Float64AttributePointer < AttributePointer
    include ErrorHandling

    # Types allowed for 64-bit floating-point attributes.
    enum Type : UInt32
      Double  = LibGL::VertexAttribPointerType::Double
      Float64 = Double

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
    # Lastly, the *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, @type : Type, stride : Int32, offset : IntPointer)
      super(size, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 64-bit floating-point number.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, type : Float64.class, stride : Int32, offset : IntPointer)
      initialize(size, :float64, stride, offset)
    end

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The `#type` will be a 64-bit floating-point number.
    # The *stride* is the number of bytes to the next value of the same attribute in the buffer.
    # The *offset* is the number of bytes from the start of attribute data in the vertex buffer.
    def initialize(size : Int32, stride : Int32, offset : IntPointer)
      initialize(size, :double, stride, offset)
    end

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    def apply(index)
      checked { LibGL.vertex_attrib_l_pointer(index, size, type, stride, pointer) }
    end
  end
end
