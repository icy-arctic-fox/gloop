require "../contextual"
require "../uniform"
require "./parameters"

module Gloop
  struct Program < Object
    # Access to active uniforms from a program.
    #
    # NOTE: The uniform *index* is different than its *location*.
    #   The *location* is used to get and set a uniform's value.
    #   The *index* is used to retrieve metadata of the uniform.
    struct Uniforms
      include Contextual
      include Indexable(Uniform)
      include Parameters

      # Number of active attributes in the program.
      #
      # - OpenGL function `glGetProgramiv`
      # - OpenGL enum: `GL_ACTIVE_UNIFORMS`
      # - OpenGL version: 2.0
      @[GLFunction("glGetProgramiv", enum: "GL_ACTIVE_UNIFORMS", version: "2.0")]
      program_parameter ActiveUniforms, size

      # Length of the longest name from the program's uniforms.
      #
      # - OpenGL function: `glGetProgramiv`
      # - OpenGL enum: `GL_ACTIVE_UNIFORM_MAX_LENGTH`
      # - OpenGL version: 2.0
      @[GLFunction("glGetProgramiv", enum: "GL_ACTIVE_UNIFORM_MAX_LENGTH", version: "2.0")]
      private program_parameter(ActiveUniformMaxLength, max_name_size) do |value|
        (value - 1) unless value.zero?
      end

      # Name of the program the uniforms are from.
      private getter name

      # Creates a references to the active uniforms in a program.
      def initialize(@context : Context, @name : Name)
      end

      # Retrieves a uniform at the specified index.
      #
      # - OpenGL function: `glGetActiveUniform`
      # - OpenGL version: 2.0
      @[GLFunction("glGetActiveUniform", version: "2.0")]
      def unsafe_fetch(index : Int)
        size = uninitialized Int32
        type = uninitialized Uniform::Type
        name = string_query(max_name_size, null_terminator: true) do |buffer, capacity, length|
          gl.get_active_uniform(@name, index, capacity, length, pointerof(size), pointerof(type), buffer)
        end

        Uniform.new(name, type, size)
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
      def [](location : Int32) : UniformLocation
        UniformLocation.new(@context, @name, location)
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
      def []?(name : String) : UniformLocation?
        return unless location = locate?(name)

        UniformLocation.new(@context, @name, location)
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
      def [](name : String) : UniformLocation
        self[name]? || raise "No uniform with name #{name} in program."
      end
    end

    # Provides access to the active uniforms in this program.
    def uniforms : Uniforms
      Uniforms.new(@context, @name)
    end
  end
end
