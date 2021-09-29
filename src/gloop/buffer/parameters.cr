require "../parameters"

module Gloop
  private module Parameters
    # Defines a getter method that retrieves an OpenGL buffer parameter.
    #
    # The *pname* is the name of the parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::BufferPNameARB`.
    # If the enum is not in `LibGL::BufferPNameARB` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # buffer_parameter BufferSize, size
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    #
    # The `#name` method is used to retrieve the buffer's name.
    private macro buffer_parameter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::BufferPNameARB.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::BufferPNameARB::{{pname.id}}
              {% end %}
          {% end %}

          %buffer = self.name
          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              gl.get_named_buffer_parameter_iv(%buffer, %pname, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              gl.get_named_buffer_parameter_iv(%buffer, %pname, pointerof(%value))
              %value

            {% elsif type <= Int64 %}
              %value = uninitialized Int64
              gl.get_named_buffer_parameter_i64v(%buffer, %pname, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              gl.get_named_buffer_parameter_iv(%buffer, %pname, pointerof(%value))
              !%value.zero?

            {% else %}
              %value = uninitialized Int32
              gl.get_named_buffer_parameter_iv(%buffer, %pname, pointerof(%value))
              {{type}}.new(%value)

            {% end %}
          end

          {% if block %}
            {{block.args.splat}} = %return
            {{yield}}
          {% else %}
            %return
          {% end %}
        end

      {% else %}
        def {{name.id}}
          %pname = {% if pname.id.includes? "::" %}
            LibGL::BufferPNameARB.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::BufferPNameARB::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_named_buffer_parameter_iv(self.name, %pname, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL buffer parameter.
    #
    # The *pname* is the parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::BufferPNameARB`.
    # If the enum is not in `LibGL::BufferPNameARB` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # buffer_parameter? BufferMapped, mapped
    # ```
    #
    # The `#name` method is used to retrieve the buffer's name.
    private macro buffer_parameter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::BufferPNameARB.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::BufferPNameARB::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_named_buffer_parameter_iv(name, pname, pointerof(value))
        !value.zero?
      end
    end

    # Defines a getter method that retrieves an OpenGL buffer parameter.
    #
    # Unlike `#buffer_parameter`, this macro retrieves the buffer information via a buffer bind target.
    #
    # The *pname* is the name of the parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::BufferPNameARB`.
    # If the enum is not in `LibGL::BufferPNameARB` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # buffer_target_parameter BufferSize, size
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    #
    # The `#target` method is used to retrieve the buffer's target.
    private macro buffer_target_parameter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::BufferPNameARB.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::BufferPNameARB::{{pname.id}}
              {% end %}
          {% end %}

          %target = self.target.to_unsafe
          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              gl.get_buffer_parameter_iv(%target, %pname, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              gl.get_buffer_parameter_iv(%target, %pname, pointerof(%value))
              %value

            {% elsif type <= Int64 %}
              %value = uninitialized Int64
              gl.get_buffer_parameter_i64v(%target, %pname, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              gl.get_buffer_parameter_iv(%target, %pname, pointerof(%value))
              !%value.zero?

            {% else %}
              %value = uninitialized Int32
              gl.get_buffer_parameter_iv(%target, %pname, pointerof(%value))
              {{type}}.new(%value)

            {% end %}
          end

          {% if block %}
            {{block.args.splat}} = %return
            {{yield}}
          {% else %}
            %return
          {% end %}
        end

      {% else %}
        def {{name.id}}
          %pname = {% if pname.id.includes? "::" %}
            LibGL::BufferPNameARB.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::BufferPNameARB::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_buffer_parameter_iv(self.target.to_unsafe, %pname, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL buffer parameter.
    #
    # Unlike `#buffer_parameter`, this macro retrieves the buffer information via a buffer bind target.
    #
    # The *pname* is the parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::BufferPNameARB`.
    # If the enum is not in `LibGL::BufferPNameARB` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # buffer_target_parameter? BufferMapped, mapped
    # ```
    #
    # The `#target` method is used to retrieve the buffer's target.
    private macro buffer_target_parameter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::BufferPNameARB.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::BufferPNameARB::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_buffer_parameter_iv(target.to_unsafe, pname, pointerof(value))
        !value.zero?
      end
    end
  end
end
