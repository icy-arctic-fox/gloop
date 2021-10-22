module Gloop
  # Mix-in providing macros to generate getters for retrieving OpenGL state parameters.
  #
  # These wrap calls to `glGet` and `glGetString`.
  private module Parameters
    # Defines a getter method that retrieves an OpenGL parameter.
    #
    # The *pname* is the name of the OpenGL parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetPName`.
    # If the enum is not in `LibGL::GetPName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
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
          %pname = {% if type <= String %}
            {% if pname.id.includes? "::" %}
              LibGL::StringName.new({{pname.id}}.to_u32!)
            {% else %}
              LibGL::StringName::{{pname.id}}
            {% end %}
          {% else %}
            {% if pname.id.includes? "::" %}
              LibGL::GetPName.new({{pname.id}}.to_u32!)
            {% else %}
              LibGL::GetPName::{{pname.id}}
            {% end %}
          {% end %}

          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              gl.get_integer_v(%pname, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              gl.get_integer_v(%pname, pointerof(%value))
              %value

            {% elsif type <= Int64 %}
              %value = uninitialized Int64
              gl.get_integer_64v(%pname, pointerof(%value))
              %value

            {% elsif type <= Float32 %}
              %value = uninitialized Float32
              gl.get_float_v(%pname, pointerof(%value))
              %value

            {% elsif type <= Float64 %}
              %value = uninitialized Float64
              gl.get_double_v(%pname, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              gl.get_boolean_v(%pname, pointerof(%value))
              !%value.zero?

            {% elsif type <= String %}
              %value = gl.get_string(%pname)
              String.new(%value)

            {% else %}
              %value = uninitialized Int32
              gl.get_integer_v(%pname, pointerof(%value))
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
            LibGL::GetPName.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::GetPName::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_integer_v(%pname, pointerof(%value))

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
    #
    # The *pname* is the OpenGL parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetPName`.
    # If the enum is not in `LibGL::GetPName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # parameter? Blend, blend
    # ```
    private macro parameter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::GetPName.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::GetPName::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_boolean_v(pname, pointerof(value))
        !value.zero?
      end
    end

    # Defines a getter method that retrieves an OpenGL parameter.
    #
    # This is similar to `#parameter`, but takes a context and defines a class method.
    #
    # The *pname* is the name of the OpenGL parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetPName`.
    # If the enum is not in `LibGL::GetPName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # class_parameter MajorVersion, major_version
    # class_parameter DepthRange, depth_range : Float32
    # class_parameter ContextProfileMask, profile : Profile
    # ```
    #
    # Specifying `String` as the type will use `glGetString`.
    # In this case, *pname* must be a enum value (again, just the name) from `LibGL::StringName`.
    #
    # ```
    # class_parameter Vendor, vendor : String
    # ```
    #
    # The name of the context argument can be changed by specifying *context_arg*.
    # It is 'context' by default.
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    private macro class_parameter(pname, name, *, context_arg = :context, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def self.{{name.var.id}}({{context_arg.id}}) : {{type}}
          %pname = {% if type <= String %}
            {% if pname.id.includes? "::" %}
              LibGL::StringName.new({{pname.id}}.to_u32!)
            {% else %}
              LibGL::StringName::{{pname.id}}
            {% end %}
          {% else %}
            {% if pname.id.includes? "::" %}
              LibGL::GetPName.new({{pname.id}}.to_u32!)
            {% else %}
              LibGL::GetPName::{{pname.id}}
            {% end %}
          {% end %}

          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              {{context_arg.id}}.gl.get_integer_v(%pname, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              {{context_arg.id}}.gl.get_integer_v(%pname, pointerof(%value))
              %value

            {% elsif type <= Int64 %}
              %value = uninitialized Int64
              {{context_arg.id}}.gl.get_integer_64v(%pname, pointerof(%value))
              %value

            {% elsif type <= Float32 %}
              %value = uninitialized Float32
              {{context_arg.id}}.gl.get_float_v(%pname, pointerof(%value))
              %value

            {% elsif type <= Float64 %}
              %value = uninitialized Float64
              {{context_arg.id}}.gl.get_float_64v(%pname, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              {{context_arg.id}}.gl.get_boolean_v(%pname, pointerof(%value))
              !%value.zero?

            {% elsif type <= String %}
              %value = {{context_arg.id}}.gl.get_string(%pname)
              String.new(%value)

            {% else %}
              %value = uninitialized Int32
              {{context_arg.id}}.gl.get_integer_v(%pname, pointerof(%value))
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
        def self.{{name.id}}(context)
          %pname = {% if pname.id.includes? "::" %}
            LibGL::GetPName.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::GetPName::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          {{context_arg.id}}.gl.get_integer_v(%pname, pointerof(%value))

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
    #
    # This is similar to `#parameter?`, but takes a context and defines a class method.
    #
    # The *pname* is the OpenGL parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetPName`.
    # If the enum is not in `LibGL::GetPName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # class_parameter? Blend, blend
    # ```
    #
    # The name of the context argument can be changed by specifying *context_arg*.
    # It is 'context' by default.
    private macro class_parameter?(pname, name, *, context_arg = :context)
      def self.{{name.id}}?({{context_arg.id}}) : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::GetPName.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::GetPName::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        {{context_arg.id}}.gl.get_boolean_v(pname, pointerof(value))
        !value.zero?
      end
    end

    # Defines a getter method that retrieves an indexed OpenGL parameter.
    #
    # The *pname* is the name of the OpenGL parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetPName`.
    # If the enum is not in `LibGL::GetPName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # index_parameter SampleMaskValue, sample_mask_value
    # ```
    #
    # The `#index` method is used to retrieve the index.
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    private macro index_parameter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          %pname = {% if pname.id.includes? "::" %}
              LibGL::GetPName.new({{pname.id}}.to_u32!)
            {% else %}
              LibGL::GetPName::{{pname.id}}
            {% end %}

          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              gl.get_integer_i_v(%pname, self.index, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              gl.get_integer_i_v(%pname, self.index, pointerof(%value))
              %value

            {% elsif type <= Int64 %}
              %value = uninitialized Int64
              gl.get_integer_64i_v(%pname, self.index, pointerof(%value))
              %value

            {% elsif type <= Float32 %}
              %value = uninitialized Float32
              gl.get_float_i_v(%pname, self.index, pointerof(%value))
              %value

            {% elsif type <= Float64 %}
              %value = uninitilized Float64
              gl.get_double_i_v(%pname, self.index, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              gl.get_boolean_i_v(%pname, self.index, pointerof(%value))
              !%value.zero?

            {% else %}
              %value = uninitialized Int32
              gl.get_integer_i_v(%pname, self.index, pointerof(%value))
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
            LibGL::GetPName.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::GetPName::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_integer_i_v(%pname, self.index, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Wrapper for fetching strings from OpenGL.
    #
    # Accepts the maximum *capacity* for the string.
    # A new string will be allocated.
    # The buffer (pointer to the string contents), capacity, and length pointer are yielded.
    # The block must call an OpenGL method to retrieve the string and the final length.
    # This method returns the string or nil if *capacity* is less than zero.
    # Set *null_terminator* to true if the length returned by OpenGL includes a null-terminator.
    private def string_query(capacity, *, null_terminator = false)
      return unless capacity
      return "" if capacity.zero?

      String.new(capacity) do |buffer|
        length = uninitialized Int32
        # Add 1 to capacity because `String.new` adds a byte for the null-terminator.
        yield buffer, capacity + 1, pointerof(length)
        length -= 1 if null_terminator
        {length, 0}
      end
    end
  end
end
