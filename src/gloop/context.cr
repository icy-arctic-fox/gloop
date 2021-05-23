require "opengl"
require "./context/*"
require "./error_handling"
require "./parameters"
require "./version"

module Gloop
  # Information about the current OpenGL context.
  module Context
    extend self
    extend ErrorHandling
    include Parameters

    # Retrieves the major portion of the OpenGL's context version.
    # For instance, if the OpenGL version is 4.6, 4 is returned.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_MAJOR_VERSION, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter MajorVersion, major_version : Int32

    # Retrieves the minor portion of the OpenGL's context version.
    # For instance, if the OpenGL version is 4.6, 6 is returned.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_MINOR_VERSION, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter MinorVersion, minor_version

    # Retrieves the OpenGL context version.
    # Combines `#major_version` and `#minor_version`.
    def version : Version
      Version.new(major_version, minor_version)
    end

    # Retrieves the profile of the current OpenGL context.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_CONTEXT_PROFILE_MASK, &value)
    # ```
    #
    # Minimum required version: 3.2
    parameter ContextProfileMask, profile : Profile
  end
end
