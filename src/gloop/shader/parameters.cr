require "../error_handling"

module Gloop
  abstract struct Shader < Object
    # Mix-in providing macros to generate getters for retrieving OpenGL shader parameters.
    # These wrap calls to `glGetShader`.
    # All calls are wrapped with error checking.
    private module Parameters
      include ErrorHandling

      # Defines a boolean getter method that retrieves an OpenGL shader parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::ShaderParameterName`.
      # The *name* will be the name of the generated method, with a question mark appended to it.
      #
      # ```
      # parameter? CompileStatus, compiled
      # ```
      #
      # The `#name` method is used to get the shader's name.
      private macro parameter?(pname, name)
        def {{name.id}}?
          checked do
            LibGL.get_shader_iv(name, LibGL::ShaderParameterName::{{pname.id}}, out value)
            !value.zero?
          end
        end
      end

      # Defines a getter method that retrieves an OpenGL shader parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::ShaderParameterName`.
      # The *name* will be the name of the generated method.
      #
      # ```
      # parameter InfoLogLength, info_log_size
      # ```
      #
      # The `#name` method is used to get the shader's name.
      private macro parameter(pname, name)
        def {{name.id}}
          checked do
            LibGL.get_shader_iv(name, LibGL::ShaderParameterName::{{pname.id}}, out value)
            value
          end
        end
      end
    end
  end
end
