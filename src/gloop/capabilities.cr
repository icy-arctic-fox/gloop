module Gloop
  # Mix-in providing macros for enabling and disabling OpenGL capabilities.
  # These methods effectively wrap calls to `glEnable`, `glDisable`, and `glIsEnabled`.
  # All calls are wrapped with error checking.
  private module Capabilities
    # Defines methods for enabling, disabling, and checking the status of a capability.
    # The *cap* is the name of the OpenGL capability to operate on.
    # This should be an enum value (just the name) from `LibGL::EnableCap`.
    # The *name* will be the name used for the generated methods.
    #
    # ```
    # capability Blend, blend
    # ```
    #
    # Four methods are generated:
    # - `enable_cap` - Enabled the capability.
    # - `disable_cap` - Disables the capability.
    # - `cap=` - Enables or disables the capability based on the flag.
    # - `cap?` - Checks if the capability is enabled.
    private macro capability(cap, name)
      # Enables the {{name.id}} capability.
      #
      # Effectively calls:
      # ```c
      # glEnable(GL_{{cap.id.underscore.upcase}})
      # ```
      def enable_{{name.id}}
        checked { LibGL.enable(LibGL::EnableCap::{{cap.id}}) }
      end

      # Disables the {{name.id}} capability.
      #
      # Effectively calls:
      # ```c
      # glDisable(GL_{{cap.id.underscore.upcase}})
      # ```
      def disable_{{name.id}}
        checked { LibGL.disable(LibGL::EnableCap::{{cap.id}}) }
      end

      # Enables or disables the {{name.id}} capability.
      # If *flag* is true, the capability will be enabled.
      # Otherwise, the capability will be disabled.
      def {{name.id}}=(flag)
        if flag
          enable_{{name.id}}
        else
          disable_{{name.id}}
        end
      end

      # Checks if the {{name.id}} capability is enabled.
      #
      # Effectively calls:
      # ```c
      # glIsEnabled(GL_{{cap.id.underscore.upcase}})
      # ```
      def {{name.id}}?
        checked do
          value = LibGL.is_enabled(LibGL::EnableCap::{{cap.id}})
          !value.false?
        end
      end
    end
  end
end
