require "./attribute_format"

module Gloop
  # Descriptor of a double-precision floating-point vertex attribute.
  struct Float64AttributeFormat < AttributeFormat
    # Creates the attribute format.
    def initialize(size : Int32, offset : UInt32)
      super(size, Type::Float64, offset)
    end
  end
end
