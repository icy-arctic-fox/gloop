require "../contextual"

module Gloop
  struct Program < Object
    # Access to active uniforms from a program.
    struct Uniforms
      include Contextual

      # Creates a references to the active uniforms in a program.
      def initialize(@context : Context, @name : Name)
      end

      # Gets the location of a named uniform.
      #
      # Returns -1 if the uniform wasn't found.
      #
      # - OpenGL function: `glGetUniformLocation`
      # - OpenGL version: 2.0
      @[GLFunction("glGetUniformLocation", version: "2.0")]
      def locate(name : String) : Int32
        gl.get_uniform_location(@name, name.to_unsafe)
      end

      # Gets the location of a named uniform.
      #
      # Returns nil if the uniform wasn't found.
      #
      # - OpenGL function: `glGetUniformLocation`
      # - OpenGL version: 2.0
      @[GLFunction("glGetUniformLocation", version: "2.0")]
      def locate?(name : String) : Int32?
        location = locate(name)
        location if location != -1
      end

      # Gets the location of a named uniform.
      #
      # Raises an error if the uniform wasn't found.
      #
      # - OpenGL function: `glGetUniformLocation`
      # - OpenGL version: 2.0
      @[GLFunction("glGetUniformLocation", version: "2.0")]
      def locate!(name : String) : Int32
        locate(name).tap do |location|
          raise "Unable to locate uniform named `#{name}`" if location == -1
        end
      end

      # References an active uniform from this program by its location.
      def [](location : Int32) : Uniform
        Uniform.new(@context, @name, location)
      end

      # References an active uniform from this program by its name.
      #
      # Returns nil if there are no uniforms with the specified name.
      #
      # The location of the uniform is resolved, but not cached.
      # Repeated calls to this method will resolve the location of the uniform by name.
      # It's recommended that the instance returned is kept for repeated use.
      #
      # - OpenGL function: `glGetUniformLocation`
      # - OpenGL version: 2.0
      @[GLFunction("glGetUniformLocation", version: "2.0")]
      def []?(name : String) : Uniform?
        return unless location = locate?(name)

        Uniform.new(@context, @name, location)
      end

      # References an active uniform from this program by its name.
      #
      # Raises if there are no uniforms with the specified name.
      #
      # The location of the uniform is resolved, but not cached.
      # Repeated calls to this method will resolve the location of the uniform by name.
      # It's recommended that the instance returned is kept for repeated use.
      #
      # - OpenGL function: `glGetUniformLocation`
      # - OpenGL version: 2.0
      @[GLFunction("glGetUniformLocation", version: "2.0")]
      def [](name : String) : Uniform
        self[name]? || raise "No uniform with name #{name} in program."
      end
    end

    # Provides access to the active uniforms in this program.
    def uniforms : Uniforms
      Uniforms.new(@context, @name)
    end
  end
end
