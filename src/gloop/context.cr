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

    # Retrieves the name of the company providing the OpenGL implementation.
    #
    # Effectively calls:
    # ```c
    # glGetString(GL_VENDOR)
    # ```
    #
    # Minimum required version: 2.0
    parameter Vendor, vendor : String

    # Retrieves the name of the renderer.
    # This name is typically tied to a particular configuration or hardware platform.
    #
    # Effectively calls:
    # ```c
    # glGetString(GL_VENDOR)
    # ```
    #
    # Minimum required version: 2.0
    parameter Renderer, renderer : String

    # Retrieves the version/release string.
    # This usually takes the form:
    # ```text
    # MAJOR.MINOR[.RELEASE]
    # ```
    # Vendor-specific information may follow the version string.
    #
    # Effectively calls:
    # ```c
    # glGetString(GL_VERSION)
    # ```
    #
    # Minimum required version: 2.0
    parameter Version, version_string : String

    # Retrieves the primary GLSL version.
    # This usually takes the form:
    # ```text
    # MAJOR.MINOR[.RELEASE]
    # ```
    # Vendor-specific information may follow the version string.
    #
    # Effectively calls:
    # ```c
    # glGetString(GL_SHADING_LANGUAGE_VERSION)
    # ```
    #
    # Minimum required version: 2.0
    parameter ShadingLanguageVersion, shading_language_version : String
  end
end
