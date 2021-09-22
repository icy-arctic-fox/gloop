module Gloop
  struct Program < Object
    # Representation of a compiled and linked shader program.
    struct Binary
      # Raw data of the compiled and linked program.
      getter bytes : Bytes

      # Token indicating the format of the data.
      getter format : UInt32

      # Creates the program binary.
      def initialize(@bytes : Bytes, @format : UInt32)
      end

      # Number of bytes used to store the binary.
      def size
        @bytes.size
      end

      # Retrieves a pointer to the byte data.
      def to_unsafe
        @bytes.to_unsafe
      end
    end
  end
end
