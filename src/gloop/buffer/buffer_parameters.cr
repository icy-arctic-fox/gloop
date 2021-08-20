require "../error_handling"

module Gloop
  struct Buffer < Object
    # Mix-in providing macros to generate getters for retrieving OpenGL buffer parameters.
    # These wrap calls to `glGetNamedBufferParameter`.
    # All calls are wrapped with error checking.
    private module BufferParameters
      include ErrorHandling

      # Defines a boolean getter method that retrieves an OpenGL buffer parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::BufferPNameARB`.
      # The *name* will be the name of the generated method, with a question mark appended to it.
      #
      # ```
      # buffer_parameter? BufferMapped, mapped
      # ```
      #
      # The `#name` method is used to get the buffer's name.
      private macro buffer_parameter?(pname, name)
        def {{name.id}}?
          checked do
            LibGL.get_named_buffer_parameter_iv(name, LibGL::BufferPNameARB::{{pname.id}}, out value)
            !value.zero?
          end
        end
      end

      # Defines a getter method that retrieves an OpenGL buffer parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::BufferPNameARB`.
      # The *name* will be the name of the generated method.
      #
      # ```
      # buffer_parameter BufferSize, size
      # ```
      #
      # The `#name` method is used to get the buffer's name.
      #
      # An optional block can be provided to modify the value before returning it.
      # The original value is yielded to the block.
      private macro buffer_parameter(pname, name, &block)
        def {{name.id}}
          %value = checked do
            {% if flag?(:x86_64) %}
              LibGL.get_named_buffer_parameter_i64v(name, LibGL::BufferPNameARB::{{pname.id}}, out value)
            {% else %}
              LibGL.get_named_buffer_parameter_iv(name, LibGL::BufferPNameARB::{{pname.id}}, out value)
            {% end %}
            value
          end

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% end %}
        end
      end
    end
  end
end
