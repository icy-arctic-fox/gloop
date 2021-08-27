require "./labelable"

module Gloop
  # Base class for all OpenGL objects.
  # Objects are identified by their name (an integer).
  # See: https://www.khronos.org/opengl/wiki/OpenGL_Object
  abstract struct Object
    include Labelable

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
    def self.none
      new(0_u32)
    end

    # Checks if this is a null object.
    def none?
      @name.zero?
    end

    # Unique identifier of this object.
    getter name

    # Enum idicating which type of object this is.
    abstract def object_type

    # Creates a reference to an existing object.
    # Requires the *name* of an OpenGL object.
    def initialize(@name : UInt32)
    end

    # Retrieves a reference to the object that can be used in C bindings.
    # This returns the object name.
    def to_unsafe
      @name
    end
  end
end
