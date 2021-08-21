module Gloop
  struct Program < Object
    # Mix-in used to generate program stage parameters
    private module ProgramStageParameters
      # Defines a getter method that retrieves an OpenGL program stage parameter.
      # The *pname* is the name of the OpenGL stage parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::ProgramStagePName`.
      # The *name* will be the name of the generated method.
      # The generated method will take one argument - the program stage (shader type).
      #
      # ```
      # program_stage_parameter ActiveSubroutineUniforms, active_subroutine_uniforms
      # ```
      #
      # The `#name` method is used to get the program's name.
      #
      # An optional block can be provided to modify the value before returning it.
      # The original value is yielded to the block.
      private macro program_stage_parameter(pname, name, &block)
        def {{name.id}}(stage : Shader::Type)
          %value = checked do
            LibGL.get_program_stage_iv(name, stage, LibGL::ProgramStagePName::{{pname.id}}, out value)
            value
          end

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% end %}
        end
      end

      # Retrieves the number of active subroutines
      # for the specified *stage* of the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINES, &value)
      # ```
      #
      # Minimum required version: 4.0
      program_stage_parameter ActiveSubroutines, active_subroutines

      # Retrieves the number of active subroutine uniforms
      # for the specified *stage* of the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINE_UNIFORMS, &value)
      # ```
      #
      # Minimum required version: 4.0
      program_stage_parameter ActiveSubroutineUniforms, active_subroutine_uniforms

      # Retrieves the number of active subroutine variable locations
      # for the specified *stage* of the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS, &value)
      # ```
      #
      # Minimum required version: 4.0
      program_stage_parameter ActiveSubroutineUniformLocations, active_subroutine_uniform_locations

      # Retrieves the length of the longest subroutine name
      # for the specified *stage* of the program.
      # This *does not* include the null-terminator byte.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINE_MAX_LENGTH, &value)
      # ```
      #
      # Minimum required version: 4.0
      program_stage_parameter ActiveSubroutineMaxLength, active_subroutine_max_size, &.-(1)

      # Retrieves the length of the longest subroutine uniform name
      # for the specified *stage* of the program.
      # This *does not* include the null-terminator byte.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINE_UNIFORM_MAX_LENGTH, &value)
      # ```
      #
      # Minimum required version: 4.0
      program_stage_parameter ActiveSubroutineUniformMaxLength, active_subroutine_uniform_max_size, &.-(1)
    end
  end
end
