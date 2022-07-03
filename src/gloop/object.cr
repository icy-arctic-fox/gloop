require "./contextual"
require "./labelable"

module Gloop
  # Base class for all OpenGL objects.
  #
  # Objects are identified by their name (an integer).
  #
  # See: https://www.khronos.org/opengl/wiki/OpenGL_Object
  abstract struct Object
    include Contextual
    include Labelable

    # Type used to represent OpenGL objects.
    alias Name = UInt32

    # Enum indicating the object's type.
    enum Type : LibGL::Enum
      Texture           = LibGL::ObjectIdentifier::Texture
      Framebuffer       = LibGL::ObjectIdentifier::Framebuffer
      Renderbuffer      = LibGL::ObjectIdentifier::Renderbuffer
      TransformFeedback = LibGL::ObjectIdentifier::TransformFeedback
      Buffer            = LibGL::ObjectIdentifier::Buffer
      Shader            = LibGL::ObjectIdentifier::Shader
      Program           = LibGL::ObjectIdentifier::Program
      VertexArray       = LibGL::ObjectIdentifier::VertexArray
      Query             = LibGL::ObjectIdentifier::Query
      ProgramPipeline   = LibGL::ObjectIdentifier::ProgramPipeline
      Sampler           = LibGL::ObjectIdentifier::Sampler

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::ObjectIdentifier.new(value)
      end
    end

    # Non-existent instance to be used as a null object.
    def self.none(context) : self
      new(context, 0_u32)
    end

    # Checks if this is a null object.
    def none?
      @name.zero?
    end

    # Context the object belongs to.
    getter context : Context

    # Unique identifier of this object.
    getter name : Name

    # Enum indicating which type of object this is.
    abstract def object_type

    # Creates a reference to an existing object.
    #
    # Requires a reference to the *content* that owns the object and its *name*.
    def initialize(@context : Context, @name : Name)
    end

    # Wrapper for deleting multiple objects of the same type, but possibly from different contexts.
    #
    # Groups the objects by their context, then yields their common context and the object names.
    private def self.delete(objects : Enumerable(self)) : Nil
      objects.group_by(&.context).each do |context, subset|
        names = subset.map(&.to_unsafe)
        yield context, names
      end
    end

    # Constructs a string representation of the object.
    #
    # Contains the object type and its name (unique identifier).
    def to_s(io)
      io << object_type << '#' << name
    end

    # Retrieves a reference to the object that can be used in C bindings.
    #
    # This returns the object name.
    def to_unsafe
      @name
    end
  end
end
