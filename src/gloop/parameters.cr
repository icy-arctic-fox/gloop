module Gloop
  # Mix-in providing macros to generate getters for retrieving OpenGL state parameters.
  # These wrap calls to `glGet` and `glGetString`.
  private module Parameters
    # Defines a getter method that retrieves an OpenGL parameter.
    # The *pname* is the name of the OpenGL parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetPName`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # parameter MajorVersion, major_version
    # parameter DepthRange, depth_range : Float32
    # parameter ContextProfileMask, profile : Profile
    # ```
    #
    # Specifying `String` as the type will use `glGetString`.
    # In this case, *pname* must be a enum value (again, just the name) from `LibGL::StringName`.
    #
    # ```
    # parameter Vendor, vendor : String
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    private macro parameter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              gl.get_integer_v(LibGL::GetPName::{{pname.id}}, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              gl.get_integer_v(LibGL::GetPName::{{pname.id}}, pointerof(%value))
              %value

            {% elsif type <= Int64 %}
              %value = uninitialized Int64
              gl.get_integer_64v(LibGL::GetPName::{{pname.id}}, pointerof(%value))
              %value

            {% elsif type <= Float32 %}
              %value = uninitialized Float32
              gl.get_float_v(LibGL::GetPName::{{pname.id}}, pointerof(%value))
              %value

            {% elsif type <= Float64 %}
              %value = uninitialized Float64
              gl.get_float_64v(LibGL::GetPName::{{pname.id}}, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              gl.get_boolean_v(LibGL::GetPName::{{pname.id}}, pointerof(%value))
              !%value.zero?

            {% elsif type <= String %}
              %value = gl.get_string(LibGL::StringName::{{pname.id}})
              String.new(%value)

            {% else %}
              %value = uninitialized Int32
              gl.get_integer_v(LibGL::GetPName::{{pname.id}}, pointerof(%value))
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
          %value = uninitialized Int32
          gl.get_integer_v(LibGL::GetPName::{{pname.id}}, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL parameter.
    # The *pname* is the OpenGL parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetPName`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # parameter? Blend, blend
    # ```
    private macro parameter?(pname, name)
      def {{name.id}}? : Bool
        value = uninitialized Int32
        gl_call get_boolean_v(LibGL::GetPName::{{pname.id}}, pointerof(value))
        !value.zero?
      end
    end
  end
end
