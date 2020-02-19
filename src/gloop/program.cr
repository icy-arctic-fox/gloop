require "opengl"
require "./bool_conversion"
require "./error_handling"
require "./shader_factory"

module Gloop
  # Pipeline consisting of shaders used to transform vertices into pixels.
  struct Program
    include BoolConversion
    include ErrorHandling

    # Name of the program.
    # Used to reference the program.
    getter name : LibGL::UInt

    # Associates with an existing program.
    private def initialize(@name)
    end

    # Creates a new program.
    def initialize
      @name = checked { LibGL.create_program }
    end

    # Attaches a shader to the program.
    def attach(shader)
      checked { LibGL.attach_shader(name, shader) }
    end

    # Detaches a shader from the program.
    def detach(shader)
      checked { LibGL.detach_shader(name, shader) }
    end

    # Retrieves the shaders attached to the program.
    def shaders
      names = Slice(LibGL::UInt).new(shader_count, read_only: true)
      names = checked do
        LibGL.get_attached_shaders(name, names.size, out count, names)
        names[0, count]
      end

      factory = ShaderFactory.new
      names.map { |name| factory.build(name) }
    end

    # Retrieves the number of shaders attached to the program.
    def shader_count
      checked do
        LibGL.get_program_iv(name, LibGL::ProgramPropertyARB::AttachedShaders, out count)
        count
      end
    end

    # Links the attached shaders into a single program.
    # No error checking is performed on the linkage.
    # Use `#linked?` to check if the linkage was successful.
    def link
      checked { LibGL.link_program(name) }
    end

    # Links the attached shaders into a single program.
    # An error is raised if the link failed.
    def link!
      link
      raise ShaderCompilationError.new(info_log) unless linked?
    end

    # Checks if the linkage was successful.
    # Returns true if it was, or false if there was a problem.
    def linked?
      checked do
        LibGL.get_program_iv(name, LibGL::ProgramPropertyARB::LinkStatus, out result)
        int_to_bool(result)
      end
    end

    # Retrieves the information log for the program.
    # This can be inspected when a link error occurs.
    # Returns nil if there is no info log.
    def info_log?
      buffer_size = info_log_length?
      return unless buffer_size

      String.new(buffer_size) do |buffer|
        checked do
          # +1 for null-terminating character that Crystal's String.new throws in.
          LibGL.get_program_info_log(name, buffer_size + 1, out length, buffer)
          {length, 0}
        end
      end
    end

    # Retrieves the information log for the program.
    # This can be inspected when a link error occurs.
    # Raises an error if there is no source code.
    def info_log
      info_log? || raise NilAssertionError.new("No program info log")
    end

    # Length of the information log for the program, in bytes.
    # If there is no log available, then nil is returned.
    def info_log_length?
      byte_size = checked do
        LibGL.get_program_iv(name, LibGL::ProgramPropertyARB::InfoLogLength, out length)
        length
      end

      # If the size is zero, then there's no log, return nil.
      # Otherwise, return the size, minus one to account for the null-terminating character.
      unless byte_size.zero?
        byte_size - 1
      end # else - fallthrough nil
    end

    # Length of the information log for the program, in bytes.
    # Raises if there is no info log.
    def info_log_length
      info_log_length? || raise NilAssertionError.new("No program info log")
    end

    # Uses the program for the current rendering state.
    def bind
      checked { LibGL.use_program(name) }
    end

    # Deletes the program and frees memory associated to it.
    # Do not attempt to continue using the program after calling this method.
    def delete
      checked { LibGL.delete_program(name) }
    end

    # Checks if the program has been marked for deletion.
    # When true, the program is still in use for the current rendering context (orphaned),
    # and will be deleted when it is no longer in use.
    def pending_deletion?
      checked do
        LibGL.get_program_iv(name, LibGL::ProgramPropertyARB::DeleteStatus, out status)
        int_to_bool(status)
      end
    end

    # Checks if the program exists and has not been deleted.
    def exists?
      result = checked { LibGL.is_program(name) }
      int_to_bool(result)
    end

    # Generates a string containing basic information about the program.
    # The string contains the program's name.
    def to_s(io)
      io << self.class
      io << '('
      io << name
      io << ')'
    end

    # Retrieves the underlying name (identifier) used by OpenGL to reference the program.
    def to_unsafe
      name
    end
  end
end
