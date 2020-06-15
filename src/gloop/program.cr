require "opengl"
require "./bool_conversion"
require "./error_handling"
require "./labelable"
require "./program_binary"
require "./program_link_error"
require "./program_validation_error"
require "./shader_factory"
require "./vertex_attribute"

module Gloop
  # Collection of shaders used to transform vertices into pixels.
  struct Program
    include BoolConversion
    include ErrorHandling
    include Labelable

    # Creates a getter method for a program parameter.
    # The *name* is the name of the method to define.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::ProgramParameterName`.
    private macro parameter(name, pname)
      def {{name.id}}
        checked do
          LibGL.get_program_iv(@program, LibGL::ProgramPropertyARB::{{pname.id}}, out params)
          params
        end
      end
    end

    # Creates a getter method for a program parameter that returns a boolean.
    # The *name* is the name of the method to define.
    # The method name will have `?` appended to it.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::ProgramParameterName`.
    private macro parameter?(name, pname)
      def {{name.id}}?
        result = checked do
          LibGL.get_program_iv(@program, LibGL::ProgramPropertyARB::{{pname.id}}, out params)
          params
        end
        int_to_bool(result)
      end
    end

    # Creates a setter method for a program parameter that accepts a boolean.
    # The *name* is the name of the method to define.
    # The method name will have `=` appended to it.
    # The *pname* is the enum value of the parameter to update.
    # This should be an enum value from `LibGL::ProgramParameterPName`.
    private macro bool_parameter_setter(name, pname)
      def {{name.id}}=(flag)
        value = bool_to_int(flag)
        checked { LibGL.program_parameter_i(@program, LibGL::ProgramParameterPName::{{pname.id}}, value) }
      end
    end

    # Indicates whether the application intends to retrieve the binary representation of the program.
    # This should be set to true before linking and attempting to use `#binary`.
    bool_parameter_setter binary_retrievable, ProgramBinaryRetrievableHint

    # Checks if this program is pending deletion.
    # When true, the `#delete` method has been called,
    # but the program is still in use by the current rendering context.
    parameter? deleted, DeleteStatus

    # Indicates whether the shader linkage was successful.
    # Calling this after `#link` indicates the result.
    parameter? linked, LinkStatus

    # Indicates whether the progoram can be bound to individual pipeline stages.
    # This must be set to true before calling `#link` in order for it to be usable with a program pipeline.
    bool_parameter_setter separable, ProgramSeparable

    # Indicates whether the last validation check (call to `#validate`) was successful.
    parameter? valid, ValidateStatus

    # Retrieves the number of attributes in the program.
    # Unused parameters are not included in the count.
    private parameter attribute_count, ActiveAttributes

    # Retrieves the size of the compiled and linked binary program.
    # This will be zero if the link failed.
    private parameter binary_size, ProgramBinaryLength

    # Retrieves the number of bytes needed to store the info log.
    # This includes the null-terminating character.
    # If there's no info log available, then zero is returned.
    private parameter info_log_size, InfoLogLength

    # Retrieves the maximum string length of an attribute name.
    # This length includes the null-terminating character.
    private parameter max_attribute_name_size, ActiveAttributeMaxLength

    # Retrieves the maximum string length of a uniform name.
    # This length includes the null-terminating character.
    private parameter max_uniform_name_size, ActiveUniformMaxLength

    # Retrieves the number of shaders attached to the program.
    private parameter shader_count, AttachedShaders

    # Retrieves the number of uniforms in the program.
    # Unused uniforms are not included in the count.
    private parameter uniform_count, ActiveUniforms

    # Wraps an existing OpenGL program object.
    protected def initialize(@program : LibGL::UInt)
    end

    # Creates a new, empty program.
    def initialize
      @program = expect_truthy { LibGL.create_program }
    end

    # Retrieves the program currently in use.
    # Returns nil if there's no active program.
    def self.current?
      program = ErrorHandling.static_checked do
        LibGL.get_integer_v(LibGL::GetPName::CurrentProgram, out data)
        data
      end.to_u32
      program.zero? ? nil : new(program)
    end

    # Retrieves the program currently in use.
    # Raises if there's no active program.
    def self.current
      current? || raise(NilAssertionError.new("No current program"))
    end

    def attribute(location : Int)
      raise NotImplementedError.new("Program#attribute(location)")
    end

    # Retrieves the attribute with the specified name.
    def attribute(name : String)
      index = checked { LibGL.get_attrib_location(@program, name) }
      index < 0 ? nil : VertexAttribute.new(index)
    end

    # Associates an attribute index with a named input.
    def bind_attribute(name, attribute)
      checked { LibGL.bind_attrib_location(@program, attribute, name) }
    end

    # Attaches a shader to the program.
    def attach(shader)
      checked { LibGL.attach_shader(@program, shader) }
    end

    # Retrieves the binary representation of the compiled and linked program.
    def binary? : ProgramBinary?
      capacity = binary_size
      return if capacity.zero?

      ProgramBinary.new(capacity) do |buffer|
        checked do
          LibGL.get_program_binary(@program, capacity, out length, out format, buffer)
          {format, length}
        end
      end
    end

    # Retrieves the binary representation of the compiled and linked program.
    # Raises if the program binary is unavailable.
    def binary : ProgramBinary
      binary? || raise(NilAssertionError.new("Program binary unavailable"))
    end

    # Loads a program from a binary represents.
    #
    # Setting a program's binary bypasses the need to compile and link.
    # This means `#linked?` will be true.
    #
    # All uniforms are reset to their initial values when using this method.
    def binary=(binary : ProgramBinary)
      checked { LibGL.program_binary(@program, binary.format, binary.binary, binary.binary.size) }
    end

    # Frees resources held by the program
    # and invalidates the name associated with it.
    # **Do not** attempt to use this instance after calling this method.
    #
    # If a program object to be deleted is in use by the current rendering state,
    # it will be flagged for deletion,
    # but will not be deleted until it is no longer in use.
    # If a program has been marked for deletion has shaders attached to it,
    # those shaders will be automatically detached by not deleted
    # unless they have been flagged for deletion by `Shader#delete`.
    def delete
      checked { LibGL.delete_program(@program) }
    end

    # Detaches a shader from the program that was previously attached.
    # This effectively undoes `#attach`.
    #
    # If a shader has been marked for deletion by `Shader#delete`
    # and it is not attached to any programs, it will be deleted after being detached.
    def detach(shader)
      checked { LibGL.detach_shader(@program, shader) }
    end

    # Checks if the program exists and has not been fully deleted.
    #
    # A program marked for deletion with `#delete`
    # but still part of the rendering state is considered to still exist.
    def exists?
      result = expect_truthy { LibGL.is_program(@program) }
      int_to_bool(result)
    end

    # Retrieves information about the program's linkage and validation.
    # An empty string will be returned if there's no log available.
    #
    # The information log is OpenGL's mechanism
    # for conveying information about the link process and validation to application developers.
    # Even if the compilation was successful, some useful information may be in it.
    def info_log
      capacity = info_log_size
      return "" if capacity.zero?

      # Subtract one from capacity here because Crystal adds a null-terminator for us.
      String.new(capacity - 1) do |buffer|
        byte_size = checked do
          LibGL.get_program_info_log(@program, capacity, out length, buffer)
          length
        end
        # Don't subtract one here because OpenGL provides the length without the null-terminator.
        {byte_size, 0}
      end
    end

    # Links the previously attached shaders.
    # Returns true if the link was successful.
    # The result of the linkage can be checked later with `#linked?`.
    def link
      checked { LibGL.link_program(@program) }
      linked?
    end

    # Links the previously attached shaders.
    # Raises a `ProgramLinkError` if the linkage failed.
    def link!
      link || raise(ProgramLinkError.new(info_log))
    end

    # Retrieves the shaders attached to the program.
    # This does not include shaders that were linked and subsequently detached.
    def shaders
      shaders = Slice(LibGL::UInt).new(shader_count, read_only: true)
      shaders = checked do
        LibGL.get_attached_shaders(@program, shaders.size, out count, shaders)
        shaders[0, count]
      end

      factory = ShaderFactory.new
      shaders.map { |shader| factory.build(shader) }
    end

    # Generates a string containing basic information about the program.
    def to_s(io)
      io << self.class
      io << '('
      io << @program
      io << ')'
    end

    # Retrieves the underlying identifier
    # that OpenGL uses to reference the program.
    def to_unsafe
      @program
    end

    def uniform(location)
      raise NotImplementedError.new("Program#uniform(location)")
    end

    def uniform(name)
      raise NotImplementedError.new("Program#uniform(name)")
    end

    # Specifies this program as the current one for the rendering context.
    def use
      checked { LibGL.use_program(@program) }
    end

    # Checks whether the program can operate in the current OpenGL context.
    # Returns true if the validation was successful.
    # The result of the validation can be checked later with `#valid?`.
    # Additional information about the validation may be contained in `#info_log`.
    def validate
      checked { LibGL.validate_program(@program) }
      valid?
    end

    # Checks whether the program can operate in the current OpenGL context.
    # If the program failed validation, an error will be raised.
    # Additional information about the validation may be contained in `#info_log`.
    def validate!
      validate || raise(ProgramValidationError.new(info_log))
    end

    # Namespace from which the name of the object is allocated.
    private def object_identifier : LibGL::ObjectIdentifier
      LibGL::ObjectIdentifier::Program
    end
  end
end
