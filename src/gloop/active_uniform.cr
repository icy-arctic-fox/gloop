module Gloop
  # Information about a usable uniform in a program.
  struct ActiveUniform
    # Index of the uniform within its program.
    getter index : Int32

    # Creates a reference to an active uniform.
    def initialize(@program : LibGL::UInt, @index : LibGL::Int)
    end
  end
end
