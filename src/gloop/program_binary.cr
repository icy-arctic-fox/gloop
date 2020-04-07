module Gloop
  # Representation of a pre-compiled and linked program.
  struct ProgramBinary
    # Numerical code that indicates to OpenGL how to interpret the binary data.
    getter format : UInt32

    # Raw content of the program binary.
    getter binary : Bytes

    # Creates a program binary from an existing source.
    def initialize(@format : UInt32, @binary : Bytes)
    end

    # Creates a program binary with an initial capacity.
    # A slice of bytes is yielded.
    # The slice should be populated with the program binary.
    # A two-element tuple must be returned by the block.
    # The first element is the OpenGL program binary format.
    # The second element is the actual length of the program binary.
    protected def initialize(capacity)
      @binary = Bytes.new(capacity, read_only: true)
      @format, size = yield @binary

      # Resize the original buffer to a smaller one if needed.
      @binary = @binary[0, size] if size < capacity
    end
  end
end
