module Gloop
  # Maintains a reference to an OpenGL object.
  # Automatically deletes the object when it is longer referenced.
  #
  # Forwards method calls to the underlying object.
  class Reference(T)
    # Creates a reference to an existing object.
    #
    # This method should not be used outside of this class as finalizing twice may cause problems.
    private def initialize(@object : T)
    end

    # Cleans up resources held by the object when it is no longer referenced.
    def finalize
      @object.delete
    end

    # Raises an error - OpenGL object references can't duplicated.
    def dup
      raise "Can't dup reference to OpenGL object"
    end

    # Generates an object of the referenced type.
    #
    # Passes along argument to the generate method on the object type.
    def self.generate(*args)
      object = T.generate(*args)
      new(object)
    end

    # Creates a new object of the referenced type.
    #
    # Passes along argument to the create method on the object type.
    def self.create(*args)
      object = T.create(*args)
      new(object)
    end

    delegate to_s, to: @object

    # Custom inspection indicating a reference and forwarding to object.
    def inspect(io)
      io << "Ref("
      io << @object
      io << ')'
    end

    forward_missing_to @object
  end
end
