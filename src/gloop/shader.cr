require "opengl"
require "./bool_conversion"
require "./error_handling"
require "./shader_compilation_error"

module Gloop
  # Common base type for all shaders.
  abstract struct Shader
    include BoolConversion
    include ErrorHandling

    # Name of the shader.
    # Used to reference the shader.
    getter name : LibGL::UInt

    # Associates with an existing shader.
    private def initialize(@name)
    end

    # Creates a new shader.
    def initialize
      @name = checked { LibGL.create_shader(type) }
    end

    # The shader's type.
    abstract def type : LibGL::ShaderType

    # Retrieves the shader's source code.
    def source
      buffer_size = source_length
      String.new(buffer_size) do |buffer|
        checked do
          LibGL.get_shader_source(name, buffer_size, out length, buffer)
          {length, 0}
        end
      end
    end

    # Length of the resulting shader source code, in bytes.
    # This includes the null-terminating character.
    def source_length
      checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::ShaderSourceLength, out length)
        length
      end
    end

    # Sets the source of the shader.
    # The *source* should be a string-like object (responds to `#to_s`).
    def source=(source)
      self.sources = StaticArray[source]
    end

    # Sets the source of the shader to multiple combined parts.
    # The *sources* should be a collection (`Enumerable`) of string-like objects (responds to `#to_s`).
    def sources=(sources)
      references = sources.map { |source| source.to_s.to_unsafe }
      if references.responds_to?(:to_unsafe)
        checked { LibGL.shader_source(name, references.size, references, nil) }
      else
        array = references.to_a
        checked { LibGL.shader_source(name, array.size, array, nil) }
      end
    end

    # Compiles the shader source code.
    # No error checking is performed on the compilation.
    # Use `#compiled?` to check if the compilation was successful.
    def compile
      checked { LibGL.compile_shader(name) }
    end

    # Compiles the shader source code.
    # An error is raised if the compilation failed.
    def compile!
      compile
      raise ShaderCompilationError.new(info_log) unless compiled?
    end

    # Checks if the compilation was successful.
    # Returns true if it was, or false if there was a problem.
    def compiled?
      checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::CompileStatus, out result)
        int_to_bool(result)
      end
    end

    # Retrieves the information log for the shader.
    # This can be inspected when a compilation error occurs.
    def info_log
      buffer_size = info_log_length
      String.new(buffer_size) do |buffer|
        checked do
          LibGL.get_shader_info_log(name, buffer_size, out length, buffer)
          {length, 0}
        end
      end
    end

    # Length of the information log for the shader, in bytes.
    # This includes the null-terminating character.
    # If there is no log available, then zero is returned.
    def info_log_length
      checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::InfoLogLength, out length)
        length
      end
    end

    # Deletes the shader and frees memory associated to it.
    # Do not attempt to continue using the shader after calling this method.
    def delete
      checked { LibGL.delete_shader(name) }
    end

    # Checks if the shader has been marked for deletion.
    # When true, the shader is still attached to a program (orphaned),
    # and will be deleted when it is no longer in use.
    def pending_deletion?
      checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::DeleteStatus, out status)
        int_to_bool(status)
      end
    end

    # Checks if the shader exists and has not been deleted.
    def exists?
      result = checked { LibGL.is_shader(name) }
      int_to_bool(result)
    end

    # Generates a string containing basic information about the shader.
    # The string contains the shader's name and type.
    def to_s(io)
      io << self.class
      io << '('
      io << name
      io << ')'
    end
  end
end
