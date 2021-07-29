require "../error_handling"

module Gloop
  abstract struct Shader < Object
    # Mix-in providing macros to generate getters for retrieving OpenGL shader parameters.
    # These wrap calls to `glGetShader`.
    # All calls are wrapped with error checking.
    private module ShaderParameters
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
      private macro shader_parameter?(pname, name)
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
      #
      # An optional block can be provided to modify the value before returning it.
      # The original value is yielded to the block.
      private macro shader_parameter(pname, name, &block)
        def {{name.id}}
          %value = checked do
            LibGL.get_shader_iv(name, LibGL::ShaderParameterName::{{pname.id}}, out value)
            value
          end

          {% if block %}
            %value.tap do |{{block.args.splat}}|
              return {{yield}}
            end
          {% end %}
        end
      end

      # Checks if the shader compilation was successful.
      #
      # Effectively calls:
      # ```c
      # glGetShaderiv(shader, GL_COMPILE_STATUS, &value)
      # ```
      #
      # Minimum required version: 2.0
      shader_parameter? CompileStatus, compiled

      # Checks if the shader has been deleted.
      #
      # Note: This property only returns true if the shader is deleted, but still exists.
      # If it doesn't exist (all resources freed), then this property can return false.
      #
      # Effectively calls:
      # ```c
      # glGetShaderiv(shader, GL_DELETE_STATUS, &value)
      # ```
      #
      # Minimum required version: 2.0
      shader_parameter? DeleteStatus, deleted

      # Retrieves the number of bytes in the shader's compilation log.
      # If the log isn't available, -1 is returned.
      #
      # Effectively calls:
      # ```c
      # glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &value)
      # ```
      #
      # Minimum required version: 2.0
      shader_parameter InfoLogLength, info_log_size, &.-(1)

      # Retrieves the number of bytes in the shader's source code.
      # This *does not* include the null-terminator byte.
      # If the source code isn't available, -1 is returned.
      #
      # Effectively calls:
      # ```c
      # glGetShaderiv(shader, GL_SHADER_SOURCE_LENGTH, &value)
      # ```
      #
      # Minimum required version: 2.0
      shader_parameter ShaderSourceLength, source_size, &.-(1)
    end
  end
end
