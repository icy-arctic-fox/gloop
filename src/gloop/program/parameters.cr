require "../parameters"

module Gloop
  module Parameters
    # Defines a getter method that retrieves an OpenGL program parameter.
    #
    # The *pname* is the name of the parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::ProgramPropertyARB`.
    # If the enum is not in `LibGL::ProgramPropertyARB` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # program_parameter InfoLogLength, info_log_size
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    #
    # The `#name` method is used to retrieve the program's name.
    private macro program_parameter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::ProgramPropertyARB.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::ProgramPropertyARB::{{pname.id}}
              {% end %}
          {% end %}

          %program = self.name
          %value = uninitialized Int32
          gl.get_program_iv(%program, %pname, pointerof(%value))
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
            LibGL::ProgramPropertyARB.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::ProgramPropertyARB::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_program_iv(self.name, %pname, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL program parameter.
    #
    # The *pname* is the parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::ProgramPropertyARB`.
    # If the enum is not in `LibGL::ProgramPropertyARB` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # program_parameter? LinkStatus, linked
    # ```
    #
    # The `#to_unsafe` method is used to retrieve the program's name.
    private macro program_parameter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::ProgramPropertyARB.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::ProgramPropertyARB::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_program_iv(name, pname, pointerof(value))
        !value.zero?
      end
    end
  end
end
