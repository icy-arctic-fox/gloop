require "./contextual"
require "./parameters"

module Gloop
  # Indexed access to all GLSL versions supported by an OpenGL context.
  struct ShadingLanguageVersionList
    include Contextual
    include Indexable(String)
    include Parameters

    def_context_initializer

    # Retrieves the number of supported GLSL versions.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_NUM_SHADING_LANGUAGE_VERSIONS`
    # - OpenGL version: 4.3
    @[GLFunction("glGetIntegerv", enum: "GL_NUM_SHADING_LANGUAGE_VERSIONS", version: "4.3")]
    parameter LibGL::NUM_SHADING_LANGUAGE_VERSIONS, size

    # Retrieves the shading version at the specified index.
    #
    # This method does not perform any bounds checking.
    #
    # - OpenGL function: `glGetStringi`
    # - OpenGL enum: `GL_SHADING_LANGAUGE_VERSION`
    # - OpenGL version: 4.3
    @[GLFunction("glGetStringi", enum: "GL_SHADING_LANGUAGE_VERSION", version: "4.3")]
    def unsafe_fetch(index : Int)
      ptr = gl.get_string_i(LibGL::StringName::ShadingLanguageVersion, index.to_u32)
      String.new(ptr)
    end
  end

  struct Context
    # Retrieves a list of supported GLSL versions for this context.
    def shading_language_versions : ShadingLanguageVersionList
      ShadingLanguageVersionList.new(self)
    end
  end
end
