require "../error_handling"

module Gloop
  struct Program < Object
    # Mix-in providing macros to generate getters for retrieving OpenGL program parameters.
    # These wrap calls to `glGetProgram`.
    # All calls are wrapped with error checking.
    private module Parameters
      include ErrorHandling

      # Defines a boolean getter method that retrieves an OpenGL program parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::ProgramPropertyARB`.
      # The *name* will be the name of the generated method, with a question mark appended to it.
      #
      # ```
      # parameter? LinkStatus, linked
      # ```
      #
      # The `#name` method is used to get the program's name.
      private macro parameter?(pname, name)
        def {{name.id}}?
          checked do
            LibGL.get_program_iv(name, LibGL::ProgramPropertyARB::{{pname.id}}, out value)
            !value.zero?
          end
        end
      end

      # Defines a getter method that retrieves an OpenGL program parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::ProgramPropertyARB`.
      # The *name* will be the name of the generated method.
      #
      # ```
      # parameter InfoLogLength, info_log_size
      # ```
      #
      # The `#name` method is used to get the program's name.
      private macro parameter(pname, name)
        def {{name.id}}
          checked do
            LibGL.get_program_iv(name, LibGL::ProgramPropertyARB::{{pname.id}}, out value)
            value
          end
        end
      end
    end
  end
end
