require "./error_handling"
require "./object"
require "./shader/*"

module Gloop
  # Base type for all shaders.
  # Encapsulates functionality for working with a stage of the graphics processing pipeline.
  # See: https://www.khronos.org/opengl/wiki/Shader
  abstract struct Shader < Object
    extend ErrorHandling
    include ErrorHandling
    include Parameters

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
      value = checked do
        LibGL.get_shader_iv(name, LibGL::ShaderParameterName::ShaderType, out value)
        value
      end
      Type.from_value(value)
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
    parameter? CompileStatus, compiled

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
    parameter? DeleteStatus, deleted

    # Retrieves the number of bytes in the shader's compilation log.
    # This includes the null-termination character.
    # If the log isn't available, zero is returned.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter InfoLogLength, info_log_size

    # Retrieves the number of bytes in the shader's source code.
    # This includes the null-termination character.
    # If the source code isn't available, zero is returned.
    #
    # Effectively calls:
    # ```c
    # glGetShaderiv(shader, GL_SHADER_SOURCE_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter ShaderSourceLength, shader_source_size

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

    def source
      raise NotImplementedError.new("#source")
    end

    def source=(source)
      self.sources = StaticArray[source]
      source # Prevent accidentally returning static array.
    end

    def sources=(sources)
      raise NotImplementedError.new("#sources=")
    end

    # Attempts to compile the shader.
    #
    # The source of the shader must be previously set by calling `#source=` or `#sources=`.
    # The result of the compilation can be checked with `#compiled?`.
    # Additional information from the compilation may be available from `#info_log`.
    #
    # Effectively calls:
    # ```c
    # glCompileShader(shader)
    # ```
    #
    # Minimum required version: 2.0
    #
    # See also: `#compile!`
    def compile
      checked { LibGL.compile_shader(self) }
    end

    # Attempts to compile the shader.
    # If the compilation fails, then `ShaderCompilationError` is raised.
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
      raise NotImplementedError.new("#compile!")
    end

    def info_log
      raise NotImplementedError.new("#info_log")
    end

    def binary=
      raise NotImplementedError.new("#binary=")
    end
  end
end
