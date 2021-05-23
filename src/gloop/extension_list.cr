require "./error_handling"
require "./extension"
require "./parameters"

module Gloop
  # Indexed access to all extensions supported by the current OpenGL context.
  struct ExtensionList
    include ErrorHandling
    include Indexable(Extension)
    include Parameters

    # Retrieves the number of extensions.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_NUM_EXTENSIONS, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter NumExtensions, size

    # Retrieves the extension at the specified index.
    # This method does not perform any bounds checking.
    #
    # Effectively calls:
    # ```c
    # glGetStringi(GL_EXTENSIONS, index)
    # ```
    #
    # Minimum required version: 3.0
    def unsafe_fetch(index : Int)
      name = expect_truthy { LibGL.get_string_i(LibGL::StringName::Extensions, index) }
      name = String.new(name)
      Extension.new(name)
    end
  end
end
