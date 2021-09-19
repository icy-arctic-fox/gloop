require "./error_handling"

module Gloop
  # Provides information about a pre-existing OpenGL context
  # and methods for calling methods within the context.
  #
  # Gloop does not provide a means of acquiring an OpenGL context.
  # Another mechanism is needed to create an OpenGL context.
  # Some possibilities are GLFW, SFML, and SDL.
  struct Context
    # Wraps calls to OpenGL functions.
    # All method calls delegate to the OpenGL function loader given in `#initialize`.
    # OpenGL function calls are wrapped with error checking if enabled (see `Context#gl`).
    private struct Proxy
      include ErrorHandling

      # Creates the proxy.
      # Function calls are delegated to *loader*.
      def initialize(@loader : OpenGL::Loader)
      end

      # Delegates calls to the OpenGL function loader.
      # Wraps calls with error checking, when enabled.
      # An `unchecked` option can be provided to conditionally check for errors.
      macro method_missing(call)
        {% if (args = call.named_args) && (arg = args.find { |arg| arg.name == :unchecked.id }) %}
          if {{arg.value}}
            @loader.{{call.name}}!({{call.args.splat}})
          else
            checked { @loader.{{call.name}}({{call.args.splat}}) }
          end
        {% elsif flag?(:release) && !flag?(:error_checking) %}
          @loader.{{call.name}}!({{call.args.splat}})
        {% else %}
          checked { @loader.{{call}} }
        {% end %}
      end
    end

    # Constructs a reference to an existing context with pre-loaded functions.
    # The *loader* should be setup with OpenGL function addresses.
    def initialize(loader : OpenGL::Loader)
      @proxy = Proxy.new(loader)
    end

    # Constructs a reference to an existing context.
    # A block must be provided that takes retrieves OpenGL functions.
    # It takes a function name and returns a pointer (address) to it for the context.
    def initialize(& : String -> Void*)
      loader = OpenGL::Loader.new
      loader.load_all { |name| yield name }
      @proxy = Proxy.new(loader)
    end

    # Provides access OpenGL functions.
    # OpenGL functions can be called by using their "Crystalized" name.
    #
    # ```
    # context.gl.bind_buffer(target, buffer)
    # ```
    #
    # See: https://gitlab.com/arctic-fox/opengl.cr/-/blob/master/README.md#libgl
    #
    # When compiling in debug mode or with error checking explicitly enabled (`-Derror_checking`),
    # function pointers are checked prior to calling them.
    # An error is raised if an unloaded or unavailable function is called.
    # Additionally, `glGetError` is called after each method.
    # An error is raised if the function produced an error.
    #
    # In release mode or with error checking disabled, these checks are skipped.
    # Calls to unloaded and unavailable functions can crash the program.
    # Errors are not raised after invalid OpenGL function calls.
    def gl
      @proxy
    end
  end
end
