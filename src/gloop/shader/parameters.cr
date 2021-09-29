require "../parameters"

module Gloop
  module Parameters
    # Defines a getter method that retrieves an OpenGL shader parameter.
    # The *pname* is the name of the parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::ShaderParameterName`.
    # If the enum is not in `LibGL::ShaderParameterName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # shader_parameter InfoLogLength, info_log_size
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    #
    # The `#name` method is used to retrieve the shader's name.
    private macro shader_parameter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::ShaderParameterName.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::ShaderParameterName::{{pname.id}}
              {% end %}
          {% end %}

          %value = uninitialized Int32
          gl.get_shader_iv(self.name, %pname, pointerof(%value))
          {% begin %}
            %return =
              {% if type < Enum %}
                {{type}}.from_value(%value)
              {% elsif type <= Int32 %}
                %value
              {% elsif type <= Bool %}
                !%value.zero?
              {% else %}
                {{type}}.new(%value)
              {% end %}
          {% end %}

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
            LibGL::ShaderParameterName.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::ShaderParameterName::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_shader_iv(self.name, %pname, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL shader parameter.
    # The *pname* is the parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::ShaderParameterName`.
    # If the enum is not in `LibGL::ShaderParameterName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # shader_parameter? CompileStatus, compiled
    # ```
    #
    # The `#to_unsafe` method is used to retrieve the shader's name.
    private macro shader_parameter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::ShaderParameterName.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::ShaderParameterName::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_shader_iv(name, pname, pointerof(value))
        !value.zero?
      end
    end
  end
end
