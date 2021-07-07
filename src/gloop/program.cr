require "./error_handling"
require "./object"
require "./program/*"
require "./shader"
require "./string_query"

module Gloop
  # Represents one or more shaders.
  # See: https://www.khronos.org/opengl/wiki/GLSL_Object#Program_objects
  struct Program < Object
    extend ErrorHandling
    include ErrorHandling
    include Parameters
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

    # Checks if the program has been deleted.
    #
    # Note: This property only returns true if the program is deleted, but still exists.
    # If it doesn't exist (all resources freed), then this property can return false.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_DELETE_STATUS, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter? DeleteStatus, deleted

    # Checks if the program has been linked successfully.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_LINK_STATUS, &value)
    # ```
    #
    # Minimum version required: 2.0
    parameter? LinkStatus, linked

    # Checks the result of the last validation.
    # See: `#validate`
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_VALIDATE_STATUS, &value)
    # ```
    #
    # Minimum version required: 2.0
    parameter? ValidateStatus, valid

    # Retrieves the number of bytes in the program's compilation log.
    # This *does not* include the null-terminator byte.
    # If the log isn't available, -1 is returned.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_INFO_LOG_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter InfoLogLength, info_log_size, &.-(1)

    # Gets the number of shaders currently attached to the program.
    # See `#shaders`
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ATTACHED_SHADERS, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter AttachedShaders, shader_count

    # Gets the number of active attribute atomic counter buffers used by the program.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ACTIVE_ATOMIC_COUNTER_BUFFERS, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter ActiveAtomicCounterBuffers, atomic_counter_buffer_count

    # Gets the number of active attributes in the program.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter ActiveAttributes, attribute_count

    # Gets the number of bytes needed to store the name
    # of the longest active attribute in the program.
    # This *does not* include the null-terminator byte.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter ActiveAttributeMaxLength, max_attribute_name_size, &.-(1)

    # Gets the number of active uniforms in the program.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter ActiveUniforms, uniform_count

    # Gets the number of bytes needed to store the name
    # of the longest active uniform in the program.
    # This *does not* include the null-terminator byte.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ACTIVE_UNIFORM_MAX_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter ActiveUniformMaxLength, max_uniform_name_size, &.-(1)

    # Gets the number of active uniform blocks in the program.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ACTIVE_UNIFORM_BLOCKS, &value)
    # ```
    #
    # Minimum required version: 3.1
    parameter ActiveUniformBlocks, uniform_block_count

    # Gets the number of bytes needed to store the name
    # of the longest active uniform block in the program.
    # This *does not* include the null-terminator byte.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_ACTIVE_UNIFORM_BLOCK_MAX_LENGTH, &value)
    # ```
    #
    # Minimum required version: 3.1
    parameter ActiveUniformBlockMaxLength, max_uniform_block_name_size, &.-(1)

    # Gets the length, in bytes, of the program's binary.
    # If linking failed, this will be zero.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_PROGRAM_BINARY_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter ProgramBinaryLength, binary_size

    # Gets the number of varying variables
    # to capture in transform feedback mode for the program.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_TRANSFORM_FEEDBACK_VARYINGS, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter TransformFeedbackVaryings, transform_feedback_varying_count

    # Gets the number of bytes needed to store the name
    # of the longest variable name used for transform feedback in the program.
    # This *does not* include the null-terminator byte.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH, &value)
    # ```
    #
    # Minimum required version: 2.0
    parameter TransformFeedbackVaryingMaxLength, max_transform_feedback_varying_name_size, &.-(1)

    # Gets the maximum number of vertices
    # that the geometry shader in the program will output.
    #
    # Effectively calls:
    # ```c
    # glGetProgramiv(program, GL_VERTICES_OUT, &value)
    # ```
    #
    # Minimum required version: 3.2
    parameter GeometryVerticesOut, max_geometry_vertices_output

    # TODO: GL_COMPUTE_WORK_GROUP_SIZE

    # TODO: GL_TRANSFORM_FEEDBACK_BUFFER_MODE

    # TODO: GL_GEOMETRY_INPUT_TYPE

    # TODO: GL_GEOMETRY_OUTPUT_TYPE

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
    #
    # Effectively calls:
    # ```c
    # glLinkProgram(program)
    # ```
    #
    # Minimum required version: 2.0
    def link
      checked { LibGL.link_program(self) }
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
