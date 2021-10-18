require "./object"
require "./program/*"
require "./shader"

module Gloop
  # Represents one or more shaders.
  #
  # See: https://www.khronos.org/opengl/wiki/GLSL_Object#Program_objects
  struct Program < Object
    include Parameters

    # Retrieves the name of the program currently in use.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_CURRENT_PROGRAM`
    # - OpenGL version: 2.0
    @[GLFunction("glGetIntegerv", enum: "GL_CURRENT_PROGRAM", version: "2.0")]
    protected class_parameter CurrentProgram, current_name : Name

    # Retrieves the current program in use.
    #
    # Returns nil if there isn't a program in use.
    #
    # See: `#use`
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_CURRENT_PROGRAM`
    # - OpenGL version: 2.0
    @[GLFunction("glGetIntegerv", enum: "GL_CURRENT_PROGRAM", version: "2.0")]
    class_parameter(CurrentProgram, current?) do |value|
      new(context, Name.new!(value)) unless value.zero?
    end

    # Retrieves the current program in use.
    #
    # Returns a null-object (`.none`) if there isn't a program in use.
    #
    # See: `#use`
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_CURRENT_PROGRAM`
    # - OpenGL version: 2.0
    @[GLFunction("glGetIntegerv", enum: "GL_CURRENT_PROGRAM", version: "2.0")]
    class_parameter(CurrentProgram, current) do |value|
      new(context, Name.new!(value))
    end

    # Checks if the program has been deleted.
    #
    # Note: This property only returns true if the program is deleted, but still exists.
    # If it doesn't exist (all resources freed), then this property can return false.
    #
    # See: `#delete`
    #
    # - OpenGL function: `glGetProgramiv`
    # - OpenGL enum: `GL_DELETE_STATUS`
    # - OpenGL version: 2.0
    @[GLFunction("glGetProgramiv", enum: "GL_DELETE_STATUS", version: "2.0")]
    program_parameter? DeleteStatus, deleted

    # Checks if the program has been linked successfully.
    #
    # See: `#link`
    #
    # - OpenGL function: `glGetProgramiv`
    # - OpenGL enum: `GL_LINK_STATUS
    # - OpenGL version: 2.0
    @[GLFunction("glGetProgramiv", enum: "GL_LINK_STATUS", version: "2.0")]
    program_parameter? LinkStatus, linked

    # Checks the result of the last validation.
    #
    # See: `#validate`
    #
    # - OpenGL function: `glGetProgramiv`
    # - OpenGL enum: `GL_VALIDATE_STATUS`
    # - OpenGL version: 2.0
    @[GLFunction("glGetProgramiv", enum: "GL_VALIDATE_STATUS", version: "2.0")]
    program_parameter? ValidateStatus, valid

    # Retrieves the size of the information log for this program.
    #
    # If the log is unavailable, nil is returned.
    #
    # See: `#info_log`
    #
    # - OpenGL function: `glGetProgramiv`
    # - OpenGL enum: `GL_INFO_LOG_LENGTH`
    # - OpenGL version: 2.0
    @[GLFunction("glGetProgramiv", enum: "GL_INFO_LOG_LENGTH", version: "2.0")]
    program_parameter(InfoLogLength, info_log_size) do |value|
      (value - 1) unless value.zero?
    end

    # Retrieves the number of shaders currently attached to the program.
    #
    # See: `#shaders`
    #
    # - OpenGL function: `glGetProgramiv`
    # - OpenGL enum: `GL_ATTACHED_SHADERS`
    # - OpenGL version: 2.0
    @[GLFunction("glGetProgramiv", enum: "GL_ATTACHED_SHADERS", version: "2.0")]
    program_parameter AttachedShaders, shader_count

    # Retrieves the length, in bytes, of the program's binary.
    #
    # If linking failed or the binary is unavailable, this will be zero.
    #
    # See: `#binary`
    #
    # - OpenGL function: `glGetProgramiv`
    # - OpenGL enum: `GL_PROGRAM_BINARY_LENGTH`
    # - OpenGL version: 4.1
    @[GLFunction("glGetProgramiv", enum: "GL_PROGRAM_BINARY_LENGTH", version: "4.1")]
    program_parameter ProgramBinaryLength, binary_size

    # TODO: Active program resources
    # TODO: GL_TRANSFORM_FEEDBACK_VARYINGS
    # TODO: GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH
    # TODO: GL_VERTICES_OUT
    # TODO: GL_COMPUTE_WORK_GROUP_SIZE
    # TODO: GL_TRANSFORM_FEEDBACK_BUFFER_MODE
    # TODO: GL_GEOMETRY_INPUT_TYPE
    # TODO: GL_GEOMETRY_OUTPUT_TYPE

    # Creates a new program.
    #
    # - OpenGL function: `glCreateProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glCreateProgram", version: "2.0")]
    def self.create(context) : self
      name = context.gl.create_program
      new(context, name)
    end

    # Indicates that this is a program object.
    def object_type
      Object::Type::Program
    end

    # Indicates to OpenGL that this program can be deleted.
    #
    # When there are no more references to the program, its resources will be released.
    #
    # See: `#deleted?`
    #
    # - OpenGL function: `glDeleteProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteProgram", version: "2.0")]
    def delete : Nil
      gl.delete_program(to_unsafe)
    end

    # Checks if this program is known to the graphics driver.
    #
    # - OpenGL function: `glIsProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glIsProgram", version: "2.0")]
    def exists?
      value = gl.is_program(to_unsafe)
      !value.false?
    end

    # Attaches the specified *shader* to this program.
    #
    # - OpenGL function: `glAttachShader`
    # - OpenGL version: 2.0
    @[GLFunction("glAttachShader", version: "2.0")]
    def attach(shader) : Nil
      gl.attach_shader(to_unsafe, shader.to_unsafe)
    end

    # Detaches the specified *shader* from this program.
    #
    # - OpenGL function: `glDetachShader`
    # - OpenGL version: 2.0
    @[GLFunction("glDetachShader", version: "2.0")]
    def detach(shader) : Nil
      gl.detach_shader(to_unsafe, shader.to_unsafe)
    end

    # Retrieves the shaders attached to the program.
    #
    # - OpenGL function: `glGetAttachedShaders`
    # - OpenGL version: 2.0
    @[GLFunction("glGetAttachedShaders", version: "2.0")]
    def shaders : Indexable(Shader)
      # Fetch the number of shaders and their names.
      count = shader_count
      names = Slice(Name).new(count)
      gl.get_attached_shaders(to_unsafe, count, pointerof(count), names.to_unsafe)

      # Use the number of shaders reported by OpenGL, in case it returned less.
      # Map the names to shader instances.
      names[0, count].map(read_only: true) do |name|
        Shader.new(context, name)
      end
    end

    # Attempts to link the shaders together to build the final program.
    #
    # Returns true if the link process was successful, false otherwise.
    #
    # See: `#link!`
    #
    # - OpenGL function: `glLinkProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glLinkProgram", version: "2.0")]
    def link : Bool
      gl.link_program(to_unsafe)
      linked?
    end

    # Attempts to link the shaders together to build the final program.
    #
    # Raises `LinkError` if the process fails.
    #
    # See: `#link`
    #
    # - OpenGL function: `glLinkProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glLinkProgram", version: "2.0")]
    def link! : Nil
      return if link

      message = info_log.try(&.each_line.first)
      raise LinkError.new(message)
    end

    # Retrieves information about the program's link process and validation.
    #
    # Nil will be returned if there's no log available.
    #
    # The information log is OpenGL's mechanism for conveying information to application developers.
    # Even if the linkage or validation was successful, some useful information may be in it.
    #
    # - OpenGL function: `glGetProgramInfoLog`
    # - OpenGL version: 2.0
    @[GLFunction("glGetProgramInfoLog", version: "2.0")]
    def info_log : String?
      string_query(info_log_size) do |buffer, capacity, length|
        gl.get_program_info_log(to_unsafe, capacity, length, buffer)
      end
    end

    # Installs this program as part of the context's rendering state.
    #
    # - OpenGL function: `glUseProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glUseProgram", version: "2.0")]
    def use : Nil
      gl.use_program(to_unsafe)
    end

    # Installs this program as part of the context's rendering state.
    #
    # Restores the previous program after the block returns.
    #
    # - OpenGL function: `glUseProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glUseProgram", version: "2.0")]
    def use
      previous = self.class.current_name(context)

      begin
        yield
      ensure
        gl.use_program(previous)
      end
    end

    # Uninstalls any existing program from the context's rendering state.
    #
    # - OpenGL function: `glUseProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glUseProgram", version: "2.0")]
    def self.uninstall(context) : Nil
      none(context).use
    end

    # Checks if the program can be used in OpenGL's current state.
    #
    # Returns true if the program is valid.
    # Stores information about validation in `#info_log`.
    #
    # See: `#valid?`
    #
    # - OpenGL function: `glValidateProgram`
    # - OpenGL version: 2.0
    @[GLFunction("glValidateProgram", version: "2.0")]
    def validate : Bool
      gl.validate_program(to_unsafe)
      valid?
    end

    # Retrieves the binary data representing the compiled and linked program.
    #
    # - OpenGL function: `glGetProgramBinary`
    # - OpenGL version: 4.1
    @[GLFunction("glGetProgramBinary", version: "4.1")]
    def binary : Binary
      size = binary_size
      format = uninitialized UInt32
      buffer = Bytes.new(size, read_only: true)
      pointer = buffer.to_unsafe.as(Void*)
      gl.get_program_binary(to_unsafe, size, pointerof(size), pointerof(format), pointer)

      buffer = buffer[0, size] if size < buffer.size # Adjust size if needed.
      Binary.new(buffer, format)
    end

    # Load an existing program binary.
    #
    # - OpenGL function: `glProgramBinary`
    # - OpenGL version: 4.1
    @[GLFunction("glProgramBinary", version: "4.1")]
    def binary=(binary)
      format = binary.format
      pointer = binary.to_unsafe.as(Void*)
      size = binary.size
      gl.program_binary(to_unsafe, format, pointer, size)
    end

    # Creates a program from an existing binary.
    #
    # See: `.create`, `#binary=`
    def self.from_binary(context, binary) : self
      create(context).tap do |program|
        program.binary = binary
      end
    end
  end

  struct Context
    # Creates an empty program.
    #
    # See: `Program.create`
    def create_program : Program
      Program.create(self)
    end

    # Retrieves the current program in use.
    #
    # Returns a `nil` if there isn't a program in use.
    #
    # See: `Program.current?`
    def program? : Program?
      Program.current?(self)
    end

    # Retrieves the current program in use.
    #
    # Returns a null-object (`Object.none`) if there isn't a program in use.
    #
    # See: `Program.current`
    def program : Program
      Program.current(self)
    end

    # Uninstalls any existing program from the context's rendering state.
    #
    # See: `Program.uninstall`
    def uninstall_program : Nil
      Program.uninstall(self)
    end
  end
end
