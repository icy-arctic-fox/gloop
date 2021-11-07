module Gloop
  struct Program < Object
    # Metadata for an active uniform in a program.
    struct Uniform
      enum Type : UInt32
        Float32
      end

      # Name of the uniform.
      #
      # The name may include '.' and '[]' operators.
      # This indicates a sub-item of a structure or array is referenced.
      getter name : String

      # Type of data stored by the uniform.
      getter type : Uniform::Type

      # Number of elements in the uniform if it's an array.
      getter size : Int32

      # Creates metadata about an active uniform from a program.
      def initialize(@name : String, @type : Uniform::Type, @size : Int32 = 1)
      end

      # Checks whether the uniform references an array.
      def array?
        size != 1
      end
    end
  end
end
