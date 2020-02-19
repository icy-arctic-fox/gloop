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
    protected def initialize(@name)
    end

    # Creates a new shader.
    def initialize
      @name = checked { LibGL.create_shader(type) }
    end

    # The shader's type.
    abstract def type : LibGL::ShaderType

    # Retrieves the shader's source code.
    # Returns nil if there is no source code.
    def source?
      buffer_size = source_length?
      return unless buffer_size

      String.new(buffer_size) do |buffer|
        checked do
          # +1 for null-terminating character that Crystal's String.new throws in.
          LibGL.get_shader_source(name, buffer_size + 1, out length, buffer)
          {length, 0}
        end
      end
    end

    # Retrieves the shader's source code.
    # Raises an error if there is no source code.
    def source
      source? || raise NilAssertionError.new("No shader source code")
    end

    # Length of the resulting shader source code, in bytes.
    # Returns nil if there is no source code.
    def source_length?
      byte_size = checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::ShaderSourceLength, out length)
        length
      end

      # If the size is zero, then there's no source, return nil.
      # Otherwise, return the size, minus one to account for the null-terminating character.
      unless byte_size.zero?
        byte_size - 1
      end # else - fallthrough nil
    end

    # Length of the resulting shader source code, in bytes.
    # Raises if there is no source code.
    def source_length
      source_length? || raise NilAssertionError.new("No shader source code")
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
    # Returns nil if there is no info log.
    def info_log?
      buffer_size = info_log_length?
      return unless buffer_size

      String.new(buffer_size) do |buffer|
        checked do
          # +1 for null-terminating character that Crystal's String.new throws in.
          LibGL.get_shader_info_log(name, buffer_size + 1, out length, buffer)
          {length, 0}
        end
      end
    end

    # Retrieves the information log for the shader.
    # This can be inspected when a compilation error occurs.
    # Raises an error if there is no log available.
    def info_log
      info_log? || raise NilAssertionError.new("No shader info log")
    end

    # Length of the information log for the shader, in bytes.
    # If there is no log available, then nil is returned.
    def info_log_length?
      byte_size = checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::InfoLogLength, out length)
        length
      end

      # If the size is zero, then there's no log, return nil.
      # Otherwise, return the size, minus one to account for the null-terminating character.
      unless byte_size.zero?
        byte_size - 1
      end # else - fallthrough nil
    end

    # Length of the information log for the shader, in bytes.
    # Raises if there is no info log.
    def info_log_length
      info_log_length? || raise NilAssertionError.new("No shader info log")
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

    # Retrieves the underlying name (identifier) used by OpenGL to reference the shader.
    def to_unsafe
      name
    end
  end
end
