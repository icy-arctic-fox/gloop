module Gloop
  # Captures information about additional functionality
  # exposed to the application by the OpenGL implementation.
  struct Extension
    # Name of the extension.
    getter name : String

    # Creates a reference to an extension.
    def initialize(@name : String)
    end

    # Produces a string containing the name of the extension.
    def to_s(io)
      io << @name
    end
  end
end
