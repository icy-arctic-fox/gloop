require "./contextual"
require "./extension"
require "./parameters"

module Gloop
  # Indexed access to all extensions supported by an OpenGL context.
  struct ExtensionList
    include Contextual
    include Indexable(Extension)
    include Parameters

    # Retrieves the number of extensions.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_NUM_EXTENSIONS`
    # - OpenGL version: 2.0
    @[GLFunction("glGetIntegerv", enum: "GL_NUM_EXTENSIONS", version: "2.0")]
    parameter NumExtensions, size

    # Retrieves the extension at the specified index.
    # This method does not perform any bounds checking.
    #
    # - OpenGL function: `glGetStringi`
    # - OpenGL enum: `GL_EXTENSIONS`
    # - OpenGL version: 3.0
    @[GLFunction("glGetStringi", enum: "GL_EXTENSIONS", version: "3.0")]
    def unsafe_fetch(index : Int)
      ptr = gl.get_string_i(LibGL::StringName::Extensions, index.to_u32)
      name = String.new(ptr)
      Extension.new(name)
    end
  end

  struct Context
    # Retrieves a list of extensions for this context.
    def extensions : ExtensionList
      ExtensionList.new(self)
    end
  end
end
