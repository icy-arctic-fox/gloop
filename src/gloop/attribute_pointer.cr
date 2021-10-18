require "./size"

module Gloop
  # Base type for all attribute pointer formats.
  #
  # Describes the format of data in an vertex attribute.
  abstract struct AttributePointer
    # Number of components in the attribute.
    #
    # This is normally 1, 2, 3, or 4.
    getter size : Int32

    # Number of bytes to the next value for this attribute in the buffer's data.
    getter stride : Int32

    # Relative offset of the attribute's data from the start of the buffer.
    getter address : Size

    # Creates the attribute format descriptor.
    def initialize(@size : Int32, @stride : Int32 = 0, @address : Size = 0)
    end
  end
end
