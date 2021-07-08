require "./error_handling"
require "./object"
require "./shader_compilation_error"
require "./shader/*"
require "./string_query"

module Gloop
  # Base type for all shaders.
  # Encapsulates functionality for working with a stage of the graphics processing pipeline.
  # See: https://www.khronos.org/opengl/wiki/Shader
  abstract struct Shader < Object
    extend ErrorHandling
    include ErrorHandling
    include ShaderParameters
    include StringQuery

    macro inherited
      extend ClassMethods
    end

    # Retrieves the type of an existing shader by its name.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_SHADER_TYPE, &value)
    # ```
    #
    # Minimum required version: 2.0
    def self.type_of(name)
      type = checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::ShaderType, out value)
        value
      end
      Type.from_value(type)
    end

    # Checks if a shader with the specified *name* (object ID) is known to the graphics driver.
    #
    # Effectively calls:
    # ```c
    # glIsShader(shader)
    # ```
    #
    # Minimum required version: 2.0
    def self.exists?(name)
      value = checked { LibGL.is_shader(name) }
      !value.false?
    end

    # Releases resources held by the OpenGL implementation shader compiler.
    # This method hints that resources held by the compiler can be released.
    # Additional shaders can be compiled after calling this method,
    # and the resources will be reallocated first.
    #
    # Effectively calls:
    # ```c
    # glReleaseShaderCompiler()
    # ```
    #
    # Minimum required version: 4.1
    def self.release_compiler
      LibGL.release_shader_compiler
    end

    # Checks if the shader compilation was successful.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_COMPILE_STATUS, &value)
    # ```
    #
    # Minimum required version: 2.0
    shader_parameter? CompileStatus, compiled

    # Checks if the shader has been deleted.
    #
    # Note: This property only returns true if the shader is deleted, but still exists.
    # If it doesn't exist (all resources freed), then this property can return false.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_DELETE_STATUS, &value)
    # ```
    #
    # Minimum required version: 2.0
    shader_parameter? DeleteStatus, deleted

    # Retrieves the number of bytes in the shader's compilation log.
    # If the log isn't available, -1 is returned.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    shader_parameter InfoLogLength, info_log_size, &.-(1)

    # Retrieves the number of bytes in the shader's source code.
    # This *does not* include the null-terminator byte.
    # If the source code isn't available, -1 is returned.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_SHADER_SOURCE_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    shader_parameter ShaderSourceLength, source_size, &.-(1)

    # Shader type.
    def type
      self.class.type
    end

    # Indicates that this is a shader object.
    def object_type
      Object::Type::Shader
    end

    # Indicates to OpenGL that this shader can be deleted.
    # When there are no more references to the shader, its resources will be released.
    # See: `#deleted?`
    #
    # Note: This property only returns true if the shader is deleted, but still exists.
    # If it doesn't exist (all resources freed), then this property can return false.
    #
    # Effectively calls:
    # ```c
    # glDeleteShader(shader)
    # ```
    #
    # Minimum required version: 2.0
    def delete
      checked { LibGL.delete_shader(self) }
    end

    # Checks if the shader is known to the graphics driver.
    #
    # Effectively calls:
    # ```c
    # glIsShader(shader)
    # ```
    #
    # Minimum required version: 2.0
    def exists?
      value = checked { LibGL.is_shader(self) }
      !value.false?
    end

    # Retrieves the shader's source code.
    # Nil is returned if the source is not available.
    #
    # The information log is OpenGL's mechanism
    # for conveying information about the compilation to application developers.
    # Even if the compilation was successful, some useful information may be in it.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_SHADER_SOURCE_LENGTH, &capacity)
    # char *buffer = (char *)malloc(capacity)
    # glGetShaderSource(shader, capacity, &length, buffer)
    # ```
    #
    # Minimum required version: 2.0
    def source
      string_query(source_size) do |buffer, capacity|
        LibGL.get_shader_source(self, capacity, out length, buffer)
        length
      end
    end

    # Updates the source code for the shader.
    # This does not compile the shader, it merely stores the source code.
    # Any existing source code will be replaced.
    # The *source* must be a type that can be stringified (or already a string).
    #
    # Effectively calls:
    # ```c
    # glShaderSource(shader, 1, &source, &source_length)
    # ```
    #
    # Minimum required version: 2.0
    def source=(source)
      self.sources = StaticArray[source]
    end

    # Updates the source code for the shader.
    # This does not compile the shader, it merely stores the source code.
    # Any existing source code will be replaced.
    # The *sources* must be a collection of items that can be stringified (or already strings).
    #
    # Effectively calls:
    # ```c
    # glShaderSource(shader, sizeof(sources), &sources, NULL)
    # ```
    #
    # Minimum required version: 2.0
    def sources=(sources)
      # Retrieve a pointer to each string source.
      references = sources.map(&.to_s.to_unsafe)

      # Some enumerable types allow unsafe direct access to their internals.
      # If available, use that, as it is much faster.
      # Otherwise, convert to an array, which allows direct access via `#to_unsafe`.
      references = references.to_a unless references.responds_to?(:to_unsafe)
      checked { LibGL.shader_source(self, references.size, references, nil) }
    end

    # Attempts to compile the shader.
    # Returns true if the compilation was successful, false otherwise.
    #
    # The source of the shader must be previously set by calling `#source=` or `#sources=`.
    # The result of the compilation can be checked with `#compiled?`.
    # Additional information from the compilation may be available from `#info_log`.
    #
    # Effectively calls:
    # ```c
    # glCompileShader(shader)
    # glGetShaderiv(shader, GL_COMPILE_STATUS, &value)
    # ```
    #
    # Minimum required version: 2.0
    #
    # See also: `#compile!`
    def compile
      checked { LibGL.compile_shader(self) }
      compiled?
    end

    # Attempts to compile the shader.
    # Raises `ShaderCompilationError` if the compilation fails.
    #
    # The source of the shader must be previously set by calling `#source=` or `#sources=`.
    #
    # Effectively calls:
    # ```c
    # glCompileShader(shader)
    # glGetShaderiv(shader, GL_COMPILE_STATUS, &value)
    # ```
    #
    # Minimum required version: 2.0
    #
    # See also: `#compile`
    def compile!
      return if compile

      message = info_log.try(&.each_line.first)
      raise ShaderCompilationError.new(message)
    end

    # Retrieves information about the shader's compilation.
    # Nil will be returned if there's no log available.
    #
    # The information log is OpenGL's mechanism
    # for conveying information about the compilation to application developers.
    # Even if the compilation was successful, some useful information may be in it.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &capacity)
    # char *buffer = (char *)malloc(capacity)
    # glGetShaderInfoLog(shader, capacity, &length, buffer)
    # ```
    #
    # Minimum required version: 2.0
    def info_log
      string_query(info_log_size) do |buffer, capacity|
        LibGL.get_shader_info_log(self, capacity, out length, buffer)
        length
      end
    end

    def binary=
      raise NotImplementedError.new("#binary=")
    end
  end
end
