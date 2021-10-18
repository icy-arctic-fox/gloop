require "../parameters"

module Gloop
  private module Parameters
    # Defines a getter method that retrieves an OpenGL attribute parameter.
    # Direct state access (DSA) is used.
    #
    # The *pname* is the name of the parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::VertexArrayPName`.
    # If the enum is not in `LibGL::VertexArrayPName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # array_attribute_parameter VertexAttribArraySize, size
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    #
    # The `#name` method is used to retrieve the vertex array's name.
    # The `#index` method is used to retrieve the attribute's index.
    private macro array_attribute_parameter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::VertexArrayPName.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::VertexArrayPName::{{pname.id}}
              {% end %}
          {% end %}

          %vao = self.name
          %index = self.index
          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              gl.get_vertex_array_indexed_iv(%vao, %index, %pname, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              gl.get_vertex_array_indexed_iv(%vao, %index, %pname, pointerof(%value))
              %value

            {% elsif type <= Int64 %}
              %value = uninitialized Int64
              gl.get_vertex_array_indexed_64iv(%vao, %index, %pname, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              gl.get_vertex_array_indexed_iv(%vao, %index, %pname, pointerof(%value))
              !%value.zero?

            {% else %}
              %value = uninitialized Int32
              gl.get_vertex_array_indexed_iv(%vao, %index, %pname, pointerof(%value))
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
            LibGL::VertexArrayPName.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::VertexArrayPName::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_vertex_array_indexed_iv(self.name, self.index, %pname, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL attribute parameter.
    # Direct state access (DSA) is used.
    #
    # The *pname* is the parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::VertexArrayPName`.
    # If the enum is not in `LibGL::VertexArrayPName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # array_attribute_parameter? VertexAttribArrayEnabled, enabled
    # ```
    #
    # The `#name` method is used to retrieve the vertex array's name.
    # The `#index` method is used to retrieve the attribute's index.
    private macro array_attribute_parameter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::VertexArrayPName.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::VertexArrayPName::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_vertex_array_indexed_iv(name, index, pname, pointerof(value))
        !value.zero?
      end
    end

    # Defines a getter method that retrieves an OpenGL attribute parameter.
    #
    # The *pname* is the name of the parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::VertexAttribPropertyARB`.
    # If the enum is not in `LibGL::VertexAttribPropertyARB` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # attribute_parameter VertexAttribArraySize, size
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    #
    # The `#index` method is used to retrieve the attribute's index.
    private macro attribute_parameter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::VertexAttribPropertyARB.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::VertexAttribPropertyARB::{{pname.id}}
              {% end %}
          {% end %}

          %value = uninitialized Int32
          gl.get_vertex_attrib_iv(self.index, %pname, pointerof(%value))
          %return = begin
            {% if type < Enum %}
              {{type}}.from_value(%value)
            {% elsif type <= Int32 %}
              %value
            {% elsif type <= Bool %}
              !%value.zero?
            {% else %}
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
            LibGL::VertexAttribPropertyARB.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::VertexAttribPropertyARB::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_vertex_attrib_iv(self.index, %pname, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL attribute parameter.
    #
    # The *pname* is the parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::VertexAttribPropertyARB`.
    # If the enum is not in `LibGL::VertexAttribPropertyARB` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # attribute_parameter? VertexAttribArrayEnabled, enabled
    # ```
    #
    # The `#index` method is used to retrieve the attribute's index.
    private macro attribute_parameter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::VertexAttribPropertyARB.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::VertexAttribPropertyARB::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_vertex_attrib_iv(index, pname, pointerof(value))
        !value.zero?
      end
    end
  end
end
