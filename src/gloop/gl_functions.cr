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
    private macro gl_call(call)
      context.gl_call {{call}}
    end
  end
end
