require "opengl"
require "./gloop/*"

# Object oriented OpenGL library.
module Gloop
  extend self
  include ErrorHandling

  VERSION = "0.1.0"

  # Creates a getter method for an OpenGL string.
  # The *name* is the name of the method to define.
  # The *pname* is the enum value of the parameter to retrieve.
  # This should be an enum value from `LibGL::StringName`.
  private macro gl_string(name, string_name)
    def {{name.id}}
      ptr = checked do
        LibGL.get_string(LibGL::StringName::{{string_name.id}})
      end
      String.new(ptr)
    end
  end

  # Retrieves a string containing the company responsible for the GL implementation.
  gl_string vendor, Vendor

  # Retrieves the name of the renderer.
  # This is typically the configuration of a hardware platform.
  gl_string renderer, Renderer

  # Retrieves the GL version string.
  gl_string version, Version

  # Retrieves the GLSL version string.
  gl_string shading_language_version, ShadingLanguageVersion

  @@debug_callback : Pointer(Void)?

  # Specifies the block of code to run when a debug message from OpenGL is received.
  # Be sure to enable debug output as well - `Capabilities.debug_output`.
  def on_debug_message(&callback : DebugMessage -> _)
    boxed_callback = Box.box(callback)
    @@debug_callback = boxed_callback

    LibGL.debug_message_callback(->(source, type, id, severity, length, msg, user_param) {
      unboxed_callback = Box(typeof(callback)).unbox(user_param)
      message = DebugMessage.new(source, type, severity, id, length, msg)
      unboxed_callback.call(message)
    }, boxed_callback)
  end
end
