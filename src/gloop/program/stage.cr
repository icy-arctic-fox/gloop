require "../shader/type"

module Gloop
  struct Program < Object
    # Information about a stage of a program.
    # A stage contains all shaders of a given type attached to a program.
    struct Stage
      # Defines a getter method that retrieves an OpenGL program stage parameter.
      # The *pname* is the name of the OpenGL stage parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::ProgramStagePName`.
      # The *name* will be the name of the generated method.
      #
      # ```
      # parameter ActiveSubroutineUniforms, active_subroutine_uniforms
      # ```
      #
      # An optional block can be provided to modify the value before returning it.
      # The original value is yielded to the block.
      private macro parameter(pname, name, &block)
        def {{name.id}}
          %value = checked do
            LibGL.get_program_stage_iv(@name, @stage, LibGL::ProgramStagePName::{{pname.id}}, out value)
            value
          end

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% end %}
        end
      end

      # Retrieves the number of active subroutines for this stage of the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINES, &value)
      # ```
      #
      # Minimum required version: 4.0
      parameter ActiveSubroutines, active_subroutines

      # Retrieves the number of active subroutine uniforms for this stage of the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINE_UNIFORMS, &value)
      # ```
      #
      # Minimum required version: 4.0
      parameter ActiveSubroutineUniforms, active_subroutine_uniforms

      # Retrieves the number of active subroutine variable locations for this stage of the program.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS, &value)
      # ```
      #
      # Minimum required version: 4.0
      parameter ActiveSubroutineUniformLocations, active_subroutine_uniform_locations

      # Retrieves the length of the longest subroutine name for this stage of the program.
      # This *does not* include the null-terminator byte.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINE_MAX_LENGTH, &value)
      # ```
      #
      # Minimum required version: 4.0
      parameter ActiveSubroutineMaxLength, active_subroutine_max_size, &.-(1)

      # Retrieves the length of the longest subroutine uniform name for this stage of the program.
      # This *does not* include the null-terminator byte.
      #
      # Effectively calls:
      # ```c
      # glGetProgramStageiv(program, stage, GL_ACTIVE_SUBROUTINE_UNIFORM_MAX_LENGTH, &value)
      # ```
      #
      # Minimum required version: 4.0
      parameter ActiveSubroutineUniformMaxLength, active_subroutine_uniform_max_size, &.-(1)

      # Creates a reference to a strage of a program.
      # Requires the *name* of the program and the *stage* (shader type).
      protected def initialize(@name : UInt32, @stage : Shader::Type)
      end
    end

    # Mix-in for fetching stage instances.
    module ProgramStages
      # Defines a method that returns an program stage instance.
      # The *stage* is the shader stage to reference.
      # This should be an enum value (just the name) from `Shader::Type`.
      # The *name* will be the name of the generated method.
      #
      # ```
      # program_stage Fragment, fragment_stage
      # ```
      #
      # The `name` method is used to fetch the program name.
      private macro program_stage(stage, name, &block)
        def {{name.id}} : Stage
          Stage.new(name, Shader::Type::{{stage.id}})
        end
      end

      # Interface for accessing information about the fragment stage.
      program_stage Fragment, fragment_stage

      # Interface for accessing information about the vertex stage.
      program_stage Vertex, vertex_stage

      # Interface for accessing information about the geometry stage.
      program_stage Geometry, geometry_stage

      # Interface for accessing information about the tessellation evaluation stage.
      program_stage TessellationEvaluation, tessellation_evaluation_stage

      # Interface for accessing information about the tessellation control stage.
      program_stage TessellationControl, tessellation_control_stage

      # Interface for accessing information about the compute stage.
      program_stage Compute, compute_stage
    end
  end
end
