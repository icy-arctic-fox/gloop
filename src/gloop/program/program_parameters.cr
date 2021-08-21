require "../error_handling"

module Gloop
  struct Program < Object
    # Mix-in providing macros to generate getters for retrieving OpenGL program parameters.
    # These wrap calls to `glGetProgram`.
    # All calls are wrapped with error checking.
    private module ProgramParameters
      include ErrorHandling

      # Defines a boolean getter method that retrieves an OpenGL program parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::ProgramPropertyARB`.
      # The *name* will be the name of the generated method, with a question mark appended to it.
      #
      # ```
      # program_parameter? LinkStatus, linked
      # ```
      #
      # The `#name` method is used to get the program's name.
      private macro program_parameter?(pname, name)
        def {{name.id}}?
          checked do
            LibGL.get_program_iv(name, LibGL::ProgramPropertyARB::{{pname.id}}, out value)
            !value.zero?
          end
        end
      end

      # Defines a getter method that retrieves an OpenGL program parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::ProgramPropertyARB`.
      # The *name* will be the name of the generated method.
      #
      # ```
      # program_parameter InfoLogLength, info_log_size
      # ```
      #
      # The `#name` method is used to get the program's name.
      #
      # An optional block can be provided to modify the value before returning it.
      # The original value is yielded to the block.
      private macro program_parameter(pname, name, &block)
        def {{name.id}}
          %value = checked do
            LibGL.get_program_iv(name, LibGL::ProgramPropertyARB::{{pname.id}}, out value)
            value
          end

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% end %}
        end
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
      program_parameter? DeleteStatus, deleted

      # Checks if the program has been linked successfully.
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_LINK_STATUS, &value)
      # ```
      #
      # Minimum version required: 2.0
      program_parameter? LinkStatus, linked

      # Checks the result of the last validation.
      # See: `#validate`
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_VALIDATE_STATUS, &value)
      # ```
      #
      # Minimum version required: 2.0
      program_parameter? ValidateStatus, valid

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
      program_parameter InfoLogLength, info_log_size, &.-(1)

      # Gets the number of shaders currently attached to the program.
      # See `#shaders`
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_ATTACHED_SHADERS, &value)
      # ```
      #
      # Minimum required version: 2.0
      program_parameter AttachedShaders, shader_count

      # Gets the number of active attribute atomic counter buffers used by the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_ACTIVE_ATOMIC_COUNTER_BUFFERS, &value)
      # ```
      #
      # Minimum required version: 2.0
      program_parameter ActiveAtomicCounterBuffers, atomic_counter_buffer_count

      # Gets the number of active attributes in the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES, &value)
      # ```
      #
      # Minimum required version: 2.0
      program_parameter ActiveAttributes, attribute_count

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
      program_parameter ActiveAttributeMaxLength, max_attribute_name_size, &.-(1)

      # Gets the number of active uniforms in the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &value)
      # ```
      #
      # Minimum required version: 2.0
      program_parameter ActiveUniforms, uniform_count

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
      program_parameter ActiveUniformMaxLength, max_uniform_name_size, &.-(1)

      # Gets the number of active uniform blocks in the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_ACTIVE_UNIFORM_BLOCKS, &value)
      # ```
      #
      # Minimum required version: 3.1
      program_parameter ActiveUniformBlocks, uniform_block_count

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
      program_parameter ActiveUniformBlockMaxLength, max_uniform_block_name_size, &.-(1)

      # Gets the length, in bytes, of the program's binary.
      # If linking failed, this will be zero.
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_PROGRAM_BINARY_LENGTH, &value)
      # ```
      #
      # Minimum required version: 2.0
      program_parameter ProgramBinaryLength, binary_size

      # Gets the number of varying variables
      # to capture in transform feedback mode for the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_TRANSFORM_FEEDBACK_VARYINGS, &value)
      # ```
      #
      # Minimum required version: 2.0
      program_parameter TransformFeedbackVaryings, transform_feedback_varying_count

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
      program_parameter TransformFeedbackVaryingMaxLength, max_transform_feedback_varying_name_size, &.-(1)

      # Gets the maximum number of vertices
      # that the geometry shader in the program will output.
      #
      # Effectively calls:
      # ```c
      # glGetProgramiv(program, GL_VERTICES_OUT, &value)
      # ```
      #
      # Minimum required version: 3.2
      program_parameter GeometryVerticesOut, max_geometry_vertices_output

      # TODO: GL_COMPUTE_WORK_GROUP_SIZE
      # TODO: GL_TRANSFORM_FEEDBACK_BUFFER_MODE
      # TODO: GL_GEOMETRY_INPUT_TYPE
      # TODO: GL_GEOMETRY_OUTPUT_TYPE
    end
  end
end
