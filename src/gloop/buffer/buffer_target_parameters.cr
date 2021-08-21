require "../error_handling"

module Gloop
  struct Buffer < Object
    # Mix-in providing macros to generate getters for retrieving OpenGL buffer parameters.
    # These wrap calls to `glGetBufferParameter`.
    # All calls are wrapped with error checking.
    private module BufferTargetParameters
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
      # The `#target` method is used to get the buffer binding target.
      private macro buffer_parameter?(pname, name)
        def {{name.id}}?
          checked do
            LibGL.get_buffer_parameter_iv(target, LibGL::BufferPNameARB::{{pname.id}}, out value)
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
      # The `#target` method is used to get the buffer binding target.
      #
      # An optional block can be provided to modify the value before returning it.
      # The original value is yielded to the block.
      private macro buffer_parameter(pname, name, &block)
        def {{name.id}}
          %value = checked do
            {% if flag?(:x86_64) %}
              LibGL.get_buffer_parameter_i64v(target, LibGL::BufferPNameARB::{{pname.id}}, out value)
            {% else %}
              LibGL.get_buffer_parameter_iv(target, LibGL::BufferPNameARB::{{pname.id}}, out value)
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
