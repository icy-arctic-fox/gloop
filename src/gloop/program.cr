require "./error_handling"
require "./object"
require "./parameters"
require "./program/*"
require "./program_link_error"
require "./shader"
require "./string_query"

module Gloop
  # Represents one or more shaders.
  # See: https://www.khronos.org/opengl/wiki/GLSL_Object#Program_objects
  struct Program < Object
    extend ErrorHandling
    include ErrorHandling
    include Parameters
    include ProgramParameters
    include ProgramStageParameters
    include ProgramStages
    include StringQuery

    # Creates a new program.
    #
    # Effectively calls:
    # ```c
    # glCreateProgram()
    # ```
    #
    # Minimum required version: 2.0
    def self.create
      name = expect_truthy { LibGL.create_program }
      new(name)
    end

    # Retrieves the current active program.
    # Returns nil if there isn't a program in use.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_CURRENT_PROGRAM, &program)
    # ```
    class_parameter(CurrentProgram, current) do |name|
      return if name.zero? # No active program.

      new(name.to_u32!)
    end

    # Indicates that this is a program object.
    def object_type
      Object::Type::Program
    end

    # Indicates to OpenGL that this program can be deleted.
    # When there are no more references to the program, its resources will be released.
    # See: `#deleted?`
    #
    # Note: This property only returns true if the program is deleted, but still exists.
    # If it doesn't exist (all resources freed), then this property can return false.
    #
    # Effectively calls:
    # ```c
    # glDeleteProgram(program)
    # ```
    #
    # Minimum required version: 2.0
    def delete
      checked { LibGL.delete_program(self) }
    end

    # Checks if the program is known to the graphics driver.
    #
    # Effectively calls:
    # ```c
    # glIsProgram(program)
    # ```
    #
    # Minimum required version: 2.0
    def exists?
      value = checked { LibGL.is_program(self) }
      !value.false?
    end

    # Attaches the specified *shader* to the program.
    #
    # Effectively calls:
    # ```c
    # glAttachShader(program, shader)
    # ```
    #
    # Minimum required version: 2.0
    def attach(shader)
      checked { LibGL.attach_shader(self, shader) }
    end

    # Detaches the specified *shader* from the program.
    #
    # Effectively calls:
    # ```c
    # glDetachShader(program, shader)
    # ```
    #
    # Minimum required version: 2.0
    def detach(shader)
      checked { LibGL.detach_shader(self, shader) }
    end

    # Retrieves the shaders attached to the program.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ATTACHED_SHADERS, &max_shaders)
    # glGetAttachedShaders(program, max_shaders, &count, &shaders)
    # ```
    #
    # Minimum required version: 2.0
    def shaders
      # Fetch the number of shaders and their names.
      count = shader_count
      names = Slice(UInt32).new(count)
      count = checked do
        LibGL.get_attached_shaders(self, count, out actual, names)
        actual
      end

      # Use the number of shaders reported by OpenGL.
      # Fetch the type of each shader and construct it.
      names[0, count].map do |name|
        type = Shader.type_of(name)
        create_shader(type, name)
      end
    end

    # Attempts to link the shaders together to build the final program.
    # Returns true if the link process was successful, false otherwise.
    #
    # Effectively calls:
    # ```c
    # glLinkProgram(program)
    # glGetProgramiv(program, GL_LINK_STATUS, &value)
    # ```
    #
    # Minimum required version: 2.0
    #
    # See: `#link!`
    def link
      checked { LibGL.link_program(self) }
      linked?
    end

    # Attempts to link the shaders together to build the final program.
    # Raises `ProgramLinkError` if the link process fails.
    #
    # Effectively calls:
    # ```c
    # glLinkProgram(program)
    # glGetProgramiv(program, GL_LINK_STATUS, &value)
    # ```
    #
    # Minimum required version: 2.0
    #
    # See: `#link`
    def link!
      return if link

      message = info_log.try(&.each_line.first)
      raise ProgramLinkError.new(message)
    end

    # Retrieves information about the program's link process.
    # An empty string will be returned if there's no log available.
    #
    # The information log is OpenGL's mechanism
    # for conveying information about the linking process to application developers.
    # Even if the linkage was successful, some useful information may be in it.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_INFO_LOG_LENGTH, &capacity)
    # char *buffer = (char *)malloc(capacity)
    # glGetProgramInfoLog(program, capacity, &length, buffer)
    # ```
    #
    # Minimum required version: 2.0
    def info_log
      string_query(info_log_size) do |buffer, capacity|
        LibGL.get_program_info_log(self, capacity, out length, buffer)
        length
      end
    end

    # Indicates this program should be used for the rendering pipeline.
    #
    # Effectively calls:
    # ```c
    # glUseProgram(program)
    # ```
    #
    # Minimum required version: 2.0
    def activate
      checked { LibGL.use_program(self) }
    end

    # Indicates this program should be used for the rendering pipeline.
    # Restores the previous program after the block completes.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_CURRENT_PROGRAM, &previous)
    # glUseProgram(program)
    # glUseProgram(previous)
    # ```
    #
    # Minimum required version: 2.0
    def activate
      previous = checked do
        LibGL.get_integer_v(LibGL::GetPName::CurrentProgram, out name)
        name
      end

      begin
        yield
      ensure
        checked { LibGL.use_program(previous) }
      end
    end

    # Detaches an existing program from the OpenGL state.
    #
    # Effectively calls:
    # ```c
    # glUseProgram(0)
    # ```
    #
    # Minimum required version: 2.0
    def self.deactivate
      checked { LibGL.use_program(0_u32) }
    end

    # Checks if the program can be used in OpenGL's current state.
    # Returns true if the program is valid.
    # Stores information about validation in `#info_log`.
    # See: `#valid?`
    #
    # Effectively calls:
    # ```c
    # glValidateProgram(program)
    # ```
    #
    # Minimum required version: 2.0
    def validate
      checked { LibGL.validate_program(self) }
      valid?
    end

    # Retrieves the binary data representing the compiled and linked program.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_PROGRAM_BINARY_LENGTH, &capacity);
    # buffer = malloc(capacity);
    # glGetProgramBinary(program, capacity, &size, &format, buffer);
    # ```
    #
    # Minimum required version: 4.1
    def binary
      size = binary_size
      buffer = Bytes.new(size, read_only: true)
      format = checked do
        LibGL.get_program_binary(self, size, pointerof(size), out format, buffer)
        format
      end
      buffer = buffer[0, size] # Adjust size if needed.
      Binary.new(buffer, format)
    end

    # Load an existing program binary.
    #
    # Effectively calls:
    # ```c
    # glProgramBinary(program, format, buffer, size)
    # ```
    #
    # Minimum required version: 4.1
    def binary=(binary)
      checked { LibGL.program_binary(self, binary.format, binary, binary.size) }
    end

    # Creates a program from an existing binary.
    #
    # Effectively calls:
    # ```c
    # program = glCreateProgram();
    # glProgramBinary(program, format, buffer, size);
    # ```
    #
    # Minimum required version: 4.1
    def self.from_binary(binary)
      create.tap do |program|
        program.binary = binary
      end
    end

    # Creates a single shader from its name and type.
    private def create_shader(type, name)
      case type
      in Shader::Type::Fragment               then FragmentShader.new(name)
      in Shader::Type::Vertex                 then VertexShader.new(name)
      in Shader::Type::Geometry               then GeometryShader.new(name)
      in Shader::Type::TessellationEvaluation then TessellationEvaluationShader.new(name)
      in Shader::Type::TessellationControl    then TessellationControlShader.new(name)
      in Shader::Type::Compute                then ComputeShader.new(name)
      end
    end
  end
end
