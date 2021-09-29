module Gloop
  # Mix-in providing macros for enabling and disabling OpenGL capabilities.
  # These methods effectively wrap calls to `glEnable`, `glDisable`, and `glIsEnabled`.
  module Capabilities
    # Defines methods for enabling, disabling, and checking the status of a capability.
    #
    # The *cap* is the name of the OpenGL capability to operate on.
    # This should be an enum value (just the name) from `LibGL::EnableCap`.
    # If the enum is not in `LibGL::EnableCap` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    # The *name* will be the name used for the generated methods.
    #
    # By default, the reported minimum version is 2.0,
    # but this can be changed with the *version* argument.
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
    private macro capability(cap, name, *, version = "2.0")
      capability_method_prelude(:glEnable, {{cap}}, "Enables the {{name.id}} capability.", version: {{version}})
      def enable_{{name.id}}
        %enum = capability_enum({{cap}})
        gl.enable(%enum)
      end

      capability_method_prelude(:glDisable, {{cap}}, "Disables the {{name.id}} capability.", version: {{version}})
      def disable_{{name.id}}
        %enum = capability_enum({{cap}})
        gl.disable(%enum)
      end

      capability_method_prelude(:glIsEnabled, {{cap}}, "Checks if the {{name.id}} capability is enabled.", version: {{version}})
      def {{name.id}}?
        %enum = capability_enum({{cap}})
        value = gl.is_enabled(%enum)
        !value.false?
      end

      # Enables or disables the {{name.id}} capability depending on *flag*.
      @[AlwaysInline]
      def {{name.id}}=(flag)
        flag ? enable_{{name.id}} : disable_{{name.id}}
      end
    end

    # Defines methods for enabling, disabling, and checking the status of a capability.
    #
    # This is similar to `#capability`, but is intended for types that rely on a capability to function.
    # For instance: debug output needs the `GL_DEBUG_OUTPUT` capability.
    # There is a set of methods associated with that capability that are contained in the type `Debug`.
    #
    # The *cap* is the name of the OpenGL capability to operate on.
    # This should be an enum value (just the name) from `LibGL::EnableCap`.
    # If the enum is not in `LibGL::EnableCap` (for instance, a constant under LibGL),
    # specify the full path as such: `LibGL::NUM_SHADING_LANGUAGE_VERSIONS`.
    #
    # By default, the reported minimum version is 2.0,
    # but this can be changed with the *version* argument.
    #
    # ```
    # self_capability Debug
    # ```
    #
    # Four methods are generated:
    # - `enable` - Enabled the capability.
    # - `disable` - Disables the capability.
    # - `enabled=` - Enables or disables the capability based on the flag.
    # - `enabled?` - Checks if the capability is enabled.
    private macro self_capability(cap, *, version = "2.0")
      capability_method_prelude(:glEnable, {{cap}}, "Enables the capability.", version: {{version}})
      def enable
        %enum = capability_enum({{cap}})
        gl.enable(%enum)
      end

      capability_method_prelude(:glDisable, {{cap}}, "Disables the capability.", version: {{version}})
      def disable
        %enum = capability_enum({{cap}})
        gl.disable(%enum)
      end

      capability_method_prelude(:glIsEnabled, {{cap}}, "Checks if the capability is enabled.", version: {{version}})
      def enabled?
        %enum = capability_enum({{cap}})
        value = gl.is_enabled(%enum)
        !value.false?
      end

      # Enables or disables the capability depending on *flag*.
      @[AlwaysInline]
      def enabled=(flag)
        flag ? enable : disable
      end
    end

    # Utility for getting a `LibGL::EnableCap` enum for a capability.
    private macro capability_enum(cap)
      {% if cap.id.includes? "::" %}
        LibGL::EnableCap.new({{cap.id}}.to_u32!)
      {% else %}
        LibGL::EnableCap::{{cap.id}}
      {% end %}
    end

    # Utility for constructing the documentation comments and `GLFunction` annotation.
    private macro capability_method_prelude(func, cap, doc, *, version = "2.0")
      {% if cap.id.includes? "::" %}
        # {{doc.id}}
        #
        # - OpenGL function: `{{func.id}}`
        # - OpenGL enum: `GL_{{cap.id.split("::").last}}`
        # - OpenGL version: {{version.id}}
        @[GLFunction({{func.id.stringify}}, enum: {{"GL_" + cap.id.split("::").last.stringify}}, version: {{version}})]
      {% else %}
        # {{doc.id}}
        #
        # - OpenGL function: `{{func.id}}`
        # - OpenGL enum: `GL_{{cap.id.underscore.upcase}}`
        # - OpenGL version: {{version.id}}
        @[GLFunction({{func.id.stringify}}, enum: {{"GL_" + cap.id.underscore.upcase.stringify}}, version: {{version}})]
      {% end %}
    end
  end
end
