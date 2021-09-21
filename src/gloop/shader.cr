require "./object"
require "./shader/*"

module Gloop
  # Base type for all shaders.
  # Encapsulates functionality for working with a stage of the graphics processing pipeline.
  # See: https://www.khronos.org/opengl/wiki/Shader
  struct Shader < Object
    include Parameters

    # Retrieves the type of this shader.
    #
    # - OpenGL function: `glGetShaderiv`
    # - OpenGL enum: `GL_SHADER_TYPE`
    # - OpenGL version: 2.0
    @[GLFunction("glGetShaderiv", enum: "GL_SHADER_TYPE", version: "2.0")]
    shader_parameter ShaderType, type : Type

    # Retrieves the size of the information log for this shader.
    # If the log is unavailable, nil is returned.
    #
    # See: `#info_log`
    #
    # - OpenGL function: `glGetShaderiv`
    # - OpenGL enum: `GL_INFO_LOG_LENGTH`
    # - OpenGL version: 2.0
    @[GLFunction("glGetShaderiv", enum: "GL_INFO_LOG_LENGTH", version: "2.0")]
    shader_parameter(InfoLogLength, info_log_size) do |value|
      (value - 1) unless value.zero?
    end

    # Retrieves the size of this shadaer's source code.
    # If the source is unavailable, nil is returned.
    #
    # See: `#source`
    #
    # - OpenGL function: `glGetShaderiv`
    # - OpenGL enum: `GL_SHADER_SOURCE_LENGTH`
    # - OpenGL version: 2.0
    @[GLFunction("glGetShaderiv", enum: "GL_SHADER_SOURCE_LENGTH", version: "2.0")]
    shader_parameter(ShaderSourceLength, source_size) do |value|
      (value - 1) unless value.zero?
    end

    # Checks if this shader is flagged for deletion.
    #
    # See: `#delete`
    #
    # - OpenGL function: `glGetShaderiv`
    # - OpenGL enum: `GL_DELETE_STATUS`
    # - OpenGL version: 2.0
    @[GLFunction("glGetShaderiv", enum: "GL_DELETE_STATUS", version: "2.0")]
    shader_parameter? DeleteStatus, deleted

    # Checks if this shader was compiled successfully.
    #
    # See: `#compile`
    #
    # - OpenGL function: `glGetShaderiv`
    # - OpenGL enum: `GL_COMPILE_STATUS`
    # - OpenGL version: 2.0
    @[GLFunction("glGetShaderiv", enum: "GL_COMPILE_STATUS", version: "2.0")]
    shader_parameter? CompileStatus, compiled

    # Creates an empty shader of the specified type.
    #
    # - OpenGL function: `glCreateShader`
    # - OpenGL version: 2.0
    # - OpenGL enum `GL_COMPUTE_SHADER` available in version 4.3 or higher
    @[GLFunction("glCreateShader", version: "2.0")]
    @[GLFunction("glCreateShader", enum: "GL_COMPUTE_SHADER", version: "4.3")]
    def self.create(context : Context, type : Type) : self
      name = context.gl.create_shader(type.to_unsafe)
      new(context, name)
    end

    # Indicates that this is a shader object.
    def object_type
      Object::Type::Shader
    end

    # Deletes this shader object.
    # Frees memory and invalidates the name associated with this shader object.
    # This method effectively undoes the effects of a call to `.create`.
    #
    # If this shader object is attached to a `Program` object, it will be flagged for deletion,
    # but it will not be deleted until it is no longer attached to any `Program` object, for any rendering context.
    #
    # See: `#deleted?`
    #
    # - OpenGL function: `glDeleteShader`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteShader", version: "2.0")]
    def delete
      gl.delete_shader(to_unsafe)
    end

    # Determines if this shader is known to the context.
    # Returns true if this shader was previously created with `.create` and not yet deleted with `#delete`.
    #
    # - OpenGL function: `glIsShader`
    # - OpenGL version: 2.0
    @[GLFunction("glIsShader", version: "2.0")]
    def exists?
      value = gl.is_shader(to_unsafe)
      !value.false?
    end

    # Retrieves the shader's source code.
    # This will be the concatenation if multiple sources were provided (see `#sources=`).
    # Nil is returned if the source is not available.
    #
    # - OpenGL function: `glGetShaderSource`
    # - OpenGL version: 2.0
    @[GLFunction("glGetShaderSource", version: "2.0")]
    def source : String?
      string_query(source_size) do |buffer, capacity, length|
        gl.get_shader_source(to_unsafe, capacity, length, buffer)
      end
    end

    # Updates the source code for the shader.
    # This does not compile the shader, it merely stores the source code.
    # Any existing source code will be replaced.
    # If *source* is not already a string, it will be stringified by calling `#to_s` on it.
    #
    # - OpenGL function: `glShaderSource`
    # - OpenGL version: 2.0
    @[GLFunction("glShaderSource", version: "2.0")]
    def source=(source)
      # Delegate to `#sources=` by using `StaticArray` as a lightweight wrapper.
      self.sources = StaticArray[source]
    end

    # Updates the source code for the shader.
    # This does not compile the shader, it merely stores the source code.
    # Any existing source code will be replaced.
    # The *sources* must be a collection of items that can be stringified (or already strings).
    #
    # - OpenGL function: `glShaderSource`
    # - OpenGL version: 2.0
    @[GLFunction("glShaderSource", version: "2.0")]
    def sources=(sources : Enumerable)
      # Retrieve a pointer to each string source.
      strings = sources.map(&.to_s.to_unsafe)

      # Some enumerable types allow unsafe direct access to their internals.
      # Use that if it's available, as it is much faster.
      # Otherwise, convert to an array, which allows direct access via `#to_unsafe`.
      strings = strings.to_a unless strings.responds_to?(:to_unsafe)
      gl.shader_source(name, strings.size, strings.to_unsafe, Pointer(Int32).null)
    end

    # Attempts to compile the shader.
    # Returns true if the compilation was successful, false otherwise.
    #
    # The source of the shader must be previously set by calling `#source=` or `#sources=`.
    # The result of the compilation can be checked with `#compiled?`.
    # Additional information from the compilation may be available from `#info_log`.
    #
    # See: `#compile!`
    #
    # - OpenGL function: `glCompileShader`
    # - OpenGL version: 2.0
    @[GLFunction("glCompileShader", version: "2.0")]
    def compile
      gl.compile_shader(name)
      compiled?
    end

    # Attempts to compile the shader.
    # Raises `CompilationError` if the compilation fails.
    #
    # The source of the shader must be previously set by calling `#source=` or `#sources=`.
    # Additional information from the compilation may be available from `#info_log`.
    #
    # See: `#compile`
    #
    # - OpenGL function: `glCompileShader`
    # - OpenGL version: 2.0
    @[GLFunction("glCompileShader", version: "2.0")]
    def compile!
      return if compile

      message = info_log.try(&.each_line.first)
      raise CompilationError.new(message)
    end

    # Retrieves information about the shader's compilation.
    # Nil will be returned if there's no log available.
    #
    # The information log is OpenGL's mechanism
    # for conveying information about the compilation to application developers.
    # Even if the compilation was successful, some useful information may be in it.
    #
    # - OpenGL function: `glGetShaderInfoLog`
    # - OpenGL version: 2.0
    @[GLFunction("glGetShaderInfoLog", version: "2.0")]
    def info_log
      string_query(info_log_size) do |buffer, capacity, length|
        gl.get_shader_info_log(name, capacity, length, buffer)
      end
    end

    # Wrapper for fetching strings from OpenGL.
    # Accepts the maximum *capacity* for the string.
    # A new string will be allocated.
    # The buffer (pointer to the string contents), capacity, and length pointer are yielded.
    # The block must call an OpenGL method to retrieve the string and the final length.
    # This method returns the string or nil if *capacity* is less than zero.
    private def string_query(capacity)
      return unless capacity
      return "" if capacity.zero?

      String.new(capacity) do |buffer|
        length = uninitialized Int32
        # Add 1 to capacity because `String.new` adds a byte for the null-terminator.
        yield buffer, capacity + 1, pointerof(length)
        {length, 0}
      end
    end
  end

  struct Context
    # Releases resources held by the OpenGL implementation shader compiler.
    # This method hints that resources held by the compiler can be released.
    # Additional shaders can be compiled after calling this method,
    # and the resources will be reallocated first.
    #
    # - OpenGL function: `glReleaseShaderCompiler`
    # - OpenGL version: 4.1
    @[GLFunction("glReleaseShaderCompiler", version: "4.1")]
    def release_shader_compiler
      gl.release_shader_compiler
    end

    # Creates an empty shader of the specified type.
    # See: `Shader.create`
    def create_shader(type : Shader::Type)
      Shader.create(self, type)
    end
  end
end
