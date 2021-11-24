require "./contextual"
require "./object"

module Gloop
  # Collection of the same type of objects from the same context.
  abstract struct ObjectList(T)
    include Contextual
    include Indexable(T)

    # Creates a list of objects from the same context with their names.
    def initialize(@context : Context, @names : Slice(Object::Name))
    end

    # Creates a list of objects from the same context with their names.
    def initialize(@context : Context, names : Enumerable(Object::Name))
      names = names.to_a unless names.responds_to?(:to_unsafe)
      @names = names.to_unsafe.to_slice(array.size)
    end

    # Creates a list of object from the same context.
    def initialize(@context : Context, objects : Enumerable(T))
      @names = Slice.new(objects.size, Object::Name.new!(0))
      objects.each_with_index do |object, i|
        raise "Object not from same context" if @context != object.context
        @names[i] = object.name
      end
    end

    # Returns the number of objects in this list.
    def size
      @names.size
    end

    # Retrieves a single object from the list.
    def unsafe_fetch(index : Int)
      name = @names.unsafe_fetch(index)
      T.new(@context, name)
    end

    # Retrieves the names of all objects in the list.
    def to_slice
      @names
    end

    # Retrieves a pointer to the object names.
    def to_unsafe
      @names.to_unsafe
    end
  end
end
