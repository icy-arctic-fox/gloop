module Gloop
  # Mix-in providing access to functions from an OpenGL context.
  private module GLFunctions
    # Retrieves the context for this instance.
    abstract def context

    # Provides direct access to loaded OpenGL functions.
    # These methods are unchecked.
    private def gl
      context.loader
    end

    # Calls an OpenGL function.
    # When compiling in debug mode or with error checking explicitly enabled,
    # function pointers are checked prior to calling them.
    # An error will be raised if an unloaded or unavailable function is called.
    # In release mode or with error checking disabled,
    # calls to unloaded and unavailable functions can crash the program.
    #
    # ```
    # gl_call get_integer_v(LibGL::GetPName::MajorVersion, pointerof(value))
    # ```
    private macro unchecked_gl_call(call)
      {% if flag?(:release) && !flag?(:error_checking) %}
        gl.{{call.name}}!({{call.args.splat}})
      {% else %}
        gl.{{call}}
      {% end %}
    end

    private macro unchecked_gl_call(context, call)
      {% if flag?(:release) && !flag?(:error_checking) %}
        {{context.id}}.loader.{{call.name}}!({{call.args.splat}})
      {% else %}
        {{context.id}}.loader.{{call}}
      {% end %}
    end

    # Calls an OpenGL function and checks for errors.
    # Does the same thing as `#unchecked_gl_call`, but with error handling.
    private macro gl_call(call)
      checked do
        unchecked_gl_call {{call}}
      end
    end

    private macro gl_call(context, call)
      checked do
        unchecked_gl_call {{context}}, {{call}}
      end
    end
  end
end
