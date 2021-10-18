module Gloop
  # Base type for all attribute formats.
  #
  # Describes the format of data in an vertex attribute.
  abstract struct AttributeFormat
    # Number of components in the attribute.
    #
    # This is normally 1, 2, 3, or 4.
    getter size : Int32

    # Relative offset of the attribute's data from the start of the buffer.
    getter offset : UInt32

    # Creates the attribute format descriptor.
    def initialize(@size : Int32, @offset : UInt32)
    end
  end
end
