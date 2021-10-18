require "./attribute_format"

module Gloop
  # Descriptor of a single-precision floating-point vertex attribute.
  struct Float32AttributeFormat < AttributeFormat
    # Indicates an integer range is scaled to one-based range.
    getter? normalized : Bool

    # Creates the attribute format.
    def initialize(size : Int32, type : Type, @normalized : Bool, offset : UInt32)
      super(size, type, offset)
    end
  end
end
