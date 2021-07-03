require "./error_handling"
require "./object"

module Gloop
  # Represents one or more shaders.
  # See: https://www.khronos.org/opengl/wiki/GLSL_Object#Program_objects
  struct Program < Object
    extend ErrorHandling
    include ErrorHandling

    # Creates a new program.
    #
    # Effectively calls:
    # ```c
    # glCreateProgram()
    # ```
    #
    # Minimum required version: 2.0
    def self.create
      name = expect_truthy { LibGL.create_program }
      new(name)
    end

    # Indicates that this is a program object.
    def object_type
      Object::Type::Program
    end

    # Indicates to OpenGL that this program can be deleted.
    # When there are no more references to the program, its resources will be released.
    # See: `#deleted?`
    #
    # Note: This property only returns true if the program is deleted, but still exists.
    # If it doesn't exist (all resources freed), then this property can return false.
    #
    # Effectively calls:
    # ```c
    # glDeleteProgram(program)
    # ```
    #
    # Minimum required version: 2.0
    def delete
      checked { LibGL.delete_program(self) }
    end

    # Checks if the program is known to the graphics driver.
    #
    # Effectively calls:
    # ```c
    # glIsProgram(program)
    # ```
    #
    # Minimum required version: 2.0
    def exists?
      value = checked { LibGL.is_program(self) }
      !value.false?
    end
  end
end
