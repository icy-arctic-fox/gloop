require "opengl"

module Gloop
  # Information about the current OpenGL context.
  module Context
    extend self

    # Retrieves the major portion of the running OpenGL's version.
    # For instance, if the OpenGL version is 4.6, 4 is returned.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_MAJOR_VERSION, &value)
    # ```
    #
    # Minimum required version: 2.0
    def major_version
      LibGL.get_integer_v(LibGL::GetPName::MajorVersion, out value)
      value
    end

    # Retrieves the minor portion of the running OpenGL's version.
    # For instance, if the OpenGL version is 4.6, 6 is returned.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_MINOR_VERSION, &value)
    # ```
    #
    # Minimum required version: 2.0
    def minor_version
      LibGL.get_integer_v(LibGL::GetPName::MinorVersion, out value)
      value
    end
  end
end
