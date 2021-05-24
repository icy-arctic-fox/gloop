require "./error_handling"

module Gloop
  # Mix-in providing macros to generate getters for retrieving OpenGL state parameters.
  # These wrap calls to `glGet` and `glGetString`.
  # All calls are wrapped with error checking.
  private module Parameters
    extend ErrorHandling

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
        checked do
          LibGL.get_boolean_v(LibGL::GetPName::{{pname.id}}, out value)
          !value.false?
        end
      end
    end

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
    private macro parameter(pname, name)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% if type < Enum %}
            value = checked do
              LibGL.get_integer_v(LibGL::GetPName::{{pname.id}}, out value)
              value
            end
            {{type}}.from_value(value)
          {% elsif type <= Int32 %}
            checked do
              LibGL.get_integer_v(LibGL::GetPName::{{pname.id}}, out value)
              value
            end
          {% elsif type <= Int64 %}
            checked do
              LibGL.get_integer_64v(LibGL::GetPName::{{pname.id}}, out value)
              value
            end
          {% elsif type <= Float32 %}
            checked do
              LibGL.get_float_v(LibGL::GetPName::{{pname.id}}, out value)
              value
            end
          {% elsif type <= Float64 %}
            checked do
              LibGL.get_float_64v(LibGL::GetPName::{{pname.id}}, out value)
              value
            end
          {% elsif type <= Bool %}
            checked do
              LibGL.get_boolean_v(LibGL::GetPName::{{pname.id}}, out value)
              !value.false?
            end
          {% elsif type <= String %}
            ptr = expect_truthy { LibGL.get_string(LibGL::StringName::{{pname.id}}) }
            String.new(ptr)
          {% else %}
            value = checked do
              LibGL.get_integer_v(LibGL::GetPName::{{pname.id}}, out value)
              value
            end
            {{type}}.new(value)
          {% end %}
        end
      {% else %}
        def {{name.id}}
          checked do
            LibGL.get_integer_v(LibGL::GetPName::{{pname.id}}, out value)
            value
          end
        end
      {% end %}
    end
  end
end
