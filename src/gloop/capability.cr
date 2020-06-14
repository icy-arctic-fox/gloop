require "opengl"
require "./bool_conversion"
require "./error_handling"

module Gloop
  # Queries an OpenGL capability and provides toggles.
  struct Capability
    include BoolConversion
    include ErrorHandling

    # Creates a reference to an OpenGL capability.
    protected def initialize(@capability : LibGL::EnableCap)
    end

    # Enables the capability.
    def enable
      checked { LibGL.enable(@capability) }
    end

    # Disables the capability.
    def disable
      checked { LibGL.disable(@capability) }
    end

    # Enables or disables the capability.
    def enabled=(flag)
      if flag
        enable
      else
        disable
      end
    end

    # Checks if the capability is enabled.
    def enabled?
      value = checked do
        LibGL.is_enabled(@capability)
      end
      int_to_bool(value)
    end

    # Returns the OpenGL representation of the capability.
    def to_unsafe
      @capability
    end
  end
end
