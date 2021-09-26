module Gloop
  struct Context
    # Conditionally defines a custom loader.
    #
    # If *type* is defined, then a loader method named *name* will be created.
    # A block must be provided that retrieves OpenGL functions using the loader.
    # It takes a function name as an argument and returns a pointer (address) to the function.
    # The address must correspond to the currently bound context.
    # If the function is unavailable, a null pointer should be returned by the block.
    private macro loader(type, name, &block)
      def self.{{name.id}} : self
        {% if type.resolve? %}
          new do |{{block.args.splat}}|
            {{block.body}}
          end
        {% else %}
          \{% raise "Loader #{name} is unavailable for this compilation" %}
        {% end %}
      end
    end

    # Creates a context from GLFW.
    #
    # This relies on the [GLFW](https://gitlab.com/arctic-fox/glfw.cr) shard being available.
    # The context must be current on the calling thread when calling this method.
    #
    # ```
    # # Initialization and window creation code.
    # LibGLFW.init
    # window = LibGLFW.create_window(640, 480, "Gloop", nil, nil)
    # LibGLFW.make_context_current(window)
    #
    # # Create Gloop context from GLFW.
    # context = Gloop::Context.glfw
    # ```
    loader LibGLFW, glfw do |name|
      LibGLFW.get_proc_address(name)
    end
  end
end
