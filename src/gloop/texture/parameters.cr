require "../parameters"

module Gloop
  private module Parameters
    # Defines a getter method that retrieves an OpenGL texture parameter.
    #
    # The *pname* is the name of the parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetTextureParameter`.
    # If the enum is not in `LibGL::GetTextureParameter` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # texture_parameter_getter TextureWidth, width
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    #
    # The `#name` method is used to retrieve the texture's name.
    private macro texture_parameter_getter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::GetTextureParameter.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::GetTextureParameter::{{pname.id}}
              {% end %}
          {% end %}

          %texture = self.name
          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              gl.get_texture_parameter_iv(%texture, %pname, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Float32 %}
              %value = uninitialized Float32
              gl.get_texture_parameter_fv(%texture, %pname, pointerof(%value))
              %value

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              gl.get_texture_parameter_i_iv(%texture, %pname, pointerof(%value))
              %value

            {% elsif type <= UInt32 %}
              %value = uninitialized UInt32
              gl.get_texture_parameter_i_uiv(%texture, %pname, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              gl.get_texture_parameter_i_iv(%texture, %pname, pointerof(%value))
              !%value.zero?

            {% else %}
              %value = uninitialized Int32
              gl.get_texture_parameter_iv(%texture, %pname, pointerof(%value))
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
            LibGL::GetTextureParameter.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::GetTextureParameter::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_texture_parameter_iv(self.name, %pname, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL texture parameter.
    #
    # The *pname* is the parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetTextureParameter`.
    # If the enum is not in `LibGL::GetTextureParameter` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # texture_parameter_getter? LibGL::TEXTURE_IMMUTABLE_FORMAT, immutable
    # ```
    #
    # The `#name` method is used to retrieve the texture's name.
    private macro texture_parameter_getter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::GetTextureParameter.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::GetTextureParameter::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_texture_parameter_iv(name, pname, pointerof(value))
        !value.zero?
      end
    end

    # Defines a getter method that retrieves an OpenGL texture parameter.
    #
    # Unlike `#texture_parameter_getter`, this macro retrieves the texture information via a texture bind target.
    #
    # The *pname* is the name of the parameter to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetTextureParameter`.
    # If the enum is not in `LibGL::GetTextureParameter` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is retrieved.
    # The parameter's value will be cast to the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # texture_target_parameter_getter TextureWidth, width
    # ```
    #
    # An optional block can be provided to modify the value before returning it.
    # The original value is yielded to the block.
    #
    # The `#target` method is used to retrieve the texture's target.
    private macro texture_target_parameter_getter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}} : {{type}}
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::GetTextureParameter.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::GetTextureParameter::{{pname.id}}
              {% end %}
          {% end %}

          %target = self.target.to_unsafe
          %return = begin
            {% if type < Enum %}
              %value = uninitialized Int32
              gl.get_tex_parameter_iv(%texture, %pname, pointerof(%value))
              {{type}}.from_value(%value)

            {% elsif type <= Float32 %}
              %value = uninitialized Float32
              gl.get_tex_parameter_fv(%target, %pname, pointerof(%value))
              %value

            {% elsif type <= Int32 %}
              %value = uninitialized Int32
              gl.get_tex_parameter_i_iv(%target, %pname, pointerof(%value))
              %value

            {% elsif type <= UInt32 %}
              %value = uninitialized UInt32
              gl.get_tex_parameter_i_uiv(%target, %pname, pointerof(%value))
              %value

            {% elsif type <= Bool %}
              %value = uninitialized Int32
              gl.get_tex_parameter_i_iv(%target, %pname, pointerof(%value))
              !%value.zero?

            {% else %}
              %value = uninitialized Int32
              gl.get_tex_parameter_iv(%target, %pname, pointerof(%value))
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
            LibGL::GetTextureParameter.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::GetTextureParameter::{{pname.id}}
          {% end %}

          %value = uninitialized Int32
          gl.get_tex_parameter_iv(self.target.to_unsafe, %pname, pointerof(%value))

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% else %}
            %value
          {% end %}
        end
      {% end %}
    end

    # Defines a boolean getter method that retrieves an OpenGL texture parameter.
    #
    # Unlike `#texture_parameter_getter?`, this macro retrieves the texture information via a texture bind target.
    #
    # The *pname* is the parameter name to retrieve.
    # This should be an enum value (just the name) from `LibGL::GetTextureParameter`.
    # If the enum is not in `LibGL::GetTextureParameter` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # texture_target_parameter_getter? LibGL::TEXTURE_IMMUTABLE_FORMAT, immutable
    # ```
    #
    # The `#target` method is used to retrieve the texture's target.
    private macro texture_target_parameter_getter?(pname, name)
      def {{name.id}}? : Bool
        pname = {% if pname.id.includes? "::" %}
          LibGL::GetTextureParameter.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::GetTextureParameter::{{pname.id}}
        {% end %}

        value = uninitialized Int32
        gl.get_tex_parameter_iv(target.to_unsafe, pname, pointerof(value))
        !value.zero?
      end
    end

    # Defines a setter method that updates an OpenGL texture parameter.
    #
    # The *pname* is the name of the parameter to update.
    # This should be an enum value (just the name) from `LibGL::TextureParameterName`.
    # If the enum is not in `LibGL::TextureParameterName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is stored.
    # The parameter's value will be cast from the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # texture_parameter_setter TextureWidth, width
    # ```
    #
    # An optional block can be provided to modify the value before setting it.
    # The original value is yielded to the block.
    #
    # The `#name` method is used to retrieve the texture's name.
    private macro texture_parameter_setter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}}=({{name.var.id}} : {{type}})
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::TextureParameterName.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::TextureParameterName::{{pname.id}}
              {% end %}
          {% end %}

          {% if block %}
            {{block.args.splat}} = {{name.var.id}}
            %value = {{yield}}
          {% else %}
            %value = {{name.var.id}}
          {% end %}

          %texture = self.name
          {% if type <= Float32 %}
            gl.texture_parameter_f(%texture, %pname, %value.to_f32)
          {% elsif type <= Enum %}
            gl.texture_parameter_i(%texture, %pname, %value.to_unsafe.to_i)
          {% elsif type <= Bool %}
            %bool = %value ? LibGL::Bool::True : LibGL::Bool::False
            gl.texture_parameter_i(%texture, %pname, %bool)
          {% else %}
            gl.texture_parameter_i(%texture, %pname, %value.to_i)
          {% end %}
        end

      {% else %}
        def {{name.id}}=({{name.id}})
          %pname = {% if pname.id.includes? "::" %}
            LibGL::TextureParameterName.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::TextureParameterName::{{pname.id}}
          {% end %}

          {% if block %}
            {{block.args.splat}} = {{name.id}}
            %value = {{yield}}
          {% else %}
            %value = {{name.id}}
          {% end %}

          gl.texture_parameter_i(self.name, %pname, %value.to_i)
        end
      {% end %}
    end

    # Defines a boolean setter method that updates an OpenGL texture parameter.
    #
    # The *pname* is the parameter name to update.
    # This should be an enum value (just the name) from `LibGL::TextureParameterName`.
    # If the enum is not in `LibGL::TextureParameterName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method, with a question mark appended to it.
    #
    # ```
    # texture_parameter_setter? LibGL::TEXTURE_IMMUTABLE_FORMAT, immutable
    # ```
    #
    # The `#name` method is used to retrieve the texture's name.
    private macro texture_parameter_setter?(pname, name)
      def {{name.id}}=({{name.id}})
        pname = {% if pname.id.includes? "::" %}
          LibGL::TextureParameterName.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::TextureParameterName::{{pname.id}}
        {% end %}

        bool = {{name.id}} ? LibGL::Bool::True : LibGL::Bool::False
        gl.texture_parameter_i(name, pname, bool)
      end
    end

    # Defines a setter method that updates an OpenGL texture parameter.
    #
    # Unlike `#texture_parameter_setter`, this macro updates the texture information via a texture bind target.
    #
    # The *pname* is the name of the parameter to update.
    # This should be an enum value (just the name) from `LibGL::TextureParameterName`.
    # If the enum is not in `LibGL::TextureParameterName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    # It can have a type annotation, which will control how the parameter's value is stored.
    # The parameter's value will be cast from the type.
    # For enums, the `Enum.from_value` method is used to ensure the value is known.
    # If no type is provided, it is assumed to be a 32-bit signed integer.
    #
    # ```
    # texture_target_parameter_setter TextureWidth, width
    # ```
    #
    # An optional block can be provided to modify the value before storing it.
    # The original value is yielded to the block.
    #
    # The `#target` method is used to retrieve the texture's target.
    private macro texture_target_parameter_setter(pname, name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% type = name.type.resolve %}
        def {{name.var.id}}=({{name.var.id}} : {{type}})
          {% begin %}
            %pname =
              {% if pname.id.includes? "::" %}
                LibGL::TextureParameterName.new({{pname.id}}.to_u32!)
              {% else %}
                LibGL::TextureParameterName::{{pname.id}}
              {% end %}
          {% end %}

          {% if block %}
            {{block.args.splat}} = {{name.var.id}}
            %value = {{yield}}
          {% else %}
            %value = {{name.var.id}}
          {% end %}

          %target = self.target
          {% if type <= Float32 %}
            gl.tex_parameter_f(%target, %pname, %value.to_f32)
          {% elsif type <= Enum %}
            gl.tex_parameter_i(%target, %pname, %value.to_unsafe.to_i)
          {% elsif type <= Bool %}
            %bool = %value ? LibGL::Bool::True : LibGL::Bool::False
            gl.tex_parameter_i(%target, %pname, %bool)
          {% else %}
            gl.tex_parameter_i(%target, %pname, %value.to_i)
          {% end %}
        end

      {% else %}
        def {{name.id}}=({{name.id}})
          %pname = {% if pname.id.includes? "::" %}
            LibGL::TextureParameterName.new({{pname.id}}.to_u32!)
          {% else %}
            LibGL::TextureParameterName::{{pname.id}}
          {% end %}

          {% if block %}
            {{block.args.splat}} = {{name.id}}
            %value = {{yield}}
          {% else %}
            %value = {{name.id}}
          {% end %}

          gl.tex_parameter_i(self.target, %pname, %value.to_i)
        end
      {% end %}
    end

    # Defines a boolean setter method that updates an OpenGL texture parameter.
    #
    # Unlike `#texture_parameter_setter?`, this macro updates the texture information via a texture bind target.
    #
    # The *pname* is the parameter name to update.
    # This should be an enum value (just the name) from `LibGL::TextureParameterName`.
    # If the enum is not in `LibGL::TextureParameterName` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name of the generated method.
    #
    # ```
    # texture_target_parameter_setter? LibGL::TEXTURE_IMMUTABLE_FORMAT, immutable
    # ```
    #
    # The `#target` method is used to retrieve the texture's target.
    private macro texture_target_parameter_setter?(pname, name)
      def {{name.id}}=({{name.id}})
        pname = {% if pname.id.includes? "::" %}
          LibGL::TextureParameterName.new({{pname.id}}.to_u32!)
        {% else %}
          LibGL::TextureParameterName::{{pname.id}}
        {% end %}

        bool = {{name.id}} ? LibGL::Bool::True : LibGL::Bool::False
        gl.tex_parameter_i(target, pname, bool)
      end
    end
  end
end
