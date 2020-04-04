require "opengl"
require "./bool_conversion"
require "./error_handling"
require "./shader_compilation_error"

module Gloop
  # Common base type for all shaders.
  abstract struct Shader
    include BoolConversion
    include ErrorHandling

    # Creates a getter method for a shader parameter.
    # The *name* is the name of the method to define.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::ShaderParameterName`.
    private macro parameter(name, pname)
      def {{name.id}}
        checked do
          LibGL.get_shader_iv(@shader, LibGL::ShaderParameterName::{{pname.id}}, out params)
          params
        end
      end
    end

    # Creates a getter method for a shader parameter that returns a boolean.
    # The *name* is the name of the method to define.
    # The method name will have `?` appended to it.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::ShaderParameterName`.
    private macro parameter?(name, pname)
      def {{name.id}}?
        result = checked do
          LibGL.get_shader_iv(@shader, LibGL::ShaderParameterName::{{pname.id}}, out params)
          params
        end
        int_to_bool(result)
      end
    end

    # Wraps an existing OpenGL shader object.
    def initialize(@shader : LibGL::UInt)
    end

    # Creates a new, empty shader.
    def initialize
      @shader = checked { LibGL.create_shader(type) }
    end

    # Releases resources held by the OpenGL implementation shader compiler.
    # This method hints that resources held by the compiler can be released.
    # Additional shaders can be compiled after calling this method,
    # and the resources will be reallocated first.
    def self.release_compiler
      LibGL.release_shader_compiler
    end

    # Enum value that represents the shader's type.
    protected abstract def type : LibGL::ShaderType

    # Compiles the shader from previously set source(s).
    # To check the result of the compilation, use `#compiled?`.
    def compile
      checked { LibGL.compile_shader(@shader) }
    end

    # Compiles the shader from previously set source(s).
    # Raises a `ShaderCompilationError` if the compilation failed.
    def compile!
      compile
      raise ShaderCompilationError.new(info_log) unless compiled?
    end

    # Checks if the shader has been compiled.
    parameter? compiled, CompileStatus

    # Frees resources held by the shader
    # and invalidates the name associated with it.
    # **Do not** attempt to use this instance after calling this method.
    #
    # If a shader object to be deleted is attached to a program,
    # it will be flagged for deletion,
    # but will not be deleted until it is no longer attached to any program.
    def delete
      checked { LibGL.delete_shader(@shader) }
    end

    # Checks if this shader is pending deletion.
    # When true, the `#delete` method has been called,
    # but the shader is still in use by a program.
    parameter? deleted, DeleteStatus

    # Checks if the shader exists and has not been fully deleted.
    def exists?
      result = checked { LibGL.is_shader(@shader) }
      int_to_bool(result)
    end

    # Retrieves information about the shader's compilation.
    # An empty string will be returned if there's no log available.
    #
    # The information log is OpenGL's mechanism
    # for conveying information about the compilation to application developers.
    # Even if the compilation was successful, some useful information may be in it.
    def info_log
      capacity = info_log_size
      return "" if capacity.zero?

      # Subtract one from capacity here because Crystal adds a null-terminator for us.
      String.new(capacity - 1) do |buffer|
        byte_size = checked do
          LibGL.get_shader_info_log(@shader, capacity, out length, buffer)
          length
        end
        # Don't subtract one here because OpenGL provides the length without the null-terminator.
        {byte_size, 0}
      end
    end

    # Retrieves the source code for the shader.
    # An empty string will be returned if the source code isn't available.
    # Source code might not be available if a program was created from a pre-compiled binary.
    def source
      capacity = source_size
      return "" if capacity.zero?

      # Subtract one from capacity here because Crystal adds a null-terminator for us.
      String.new(capacity - 1) do |buffer|
        byte_size = checked do
          LibGL.get_shader_source(@shader, capacity, out length, buffer)
          length
        end
        # Don't subtract one here because OpenGL provides the length without the null-terminator.
        {byte_size, 0}
      end
    end

    # Sets the source code for the shader.
    def source=(source)
      self.sources = StaticArray[source]
    end

    # Sets the source code for the shader.
    # This setter allows specifying pieces of the shader.
    # Each piece will be concatenated to create the entire source.
    def sources=(sources)
      # Retrieve a pointer to each string source.
      references = sources.map { |source| source.to_s.to_unsafe }

      # Some enumerable types allow unsafe direct access to their internals.
      # If available, use that, as it is much faster.
      # Otherwise, convert to an array, which allows unsafe direct access.
      references = references.to_a unless references.responds_to?(:to_unsafe)
      checked { LibGL.shader_source(@shader, references.size, references, nil) }
    end

    # Generates a string containing basic information about the shader.
    # The string contains the shader's name and type.
    def to_s(io)
      io << self.class
      io << '('
      io << @shader
      io << ')'
    end

    # Retrieves the underlying identifier
    # that OpenGL uses to reference the shader.
    def to_unsafe
      @shader
    end

    # Retrieves the number of bytes needed to store the info log.
    # This includes the null-terminating character.
    # If there's no info log available, then zero is returned.
    private parameter info_log_size, InfoLogLength

    # Retrieves the number of bytes needed to store the shader's source code.
    # This includes the null-terminating character.
    # If there's no source available, then zero is returned.
    private parameter source_size, ShaderSourceLength

    # Class methods that every sub-class should expose.
    module ClassMethods
      # Creates and compiles a shader from a source string.
      # To check the result of the compilation, use `Shader#compiled?`.
      def compile(source)
        new.tap do |shader|
          shader.source = source
          shader.compile
        end
      end

      # Creates and compiles a shader from a source string.
      # Raises a `ShaderCompilationError` if the compilation failed.
      def compile!(source)
        new.tap do |shader|
          shader.source = source
          shader.compile!
        end
      end

      # Creates and compiles a shader from multiple source string.
      # Each string will be concatenated to create the entire source.
      # To check the result of the compilation, use `Shader#compiled?`.
      def compile(sources : Enumerable)
        new.tap do |shader|
          shader.sources = sources
          shader.compile
        end
      end

      # Creates and compiles a shader from multiple source string.
      # Each string will be concatenated to create the entire source.
      # Raises a `ShaderCompilationError` if the compilation failed.
      def compile!(sources : Enumerable)
        new.tap do |shader|
          shader.sources = sources
          shader.compile!
        end
      end
    end

    # Automatically add the class methods on every child.
    macro inherited
      extend ClassMethods
    end
  end
end
