require "./severity"
require "./source"
require "./type"

module Gloop::Debug
  # Debug information received from OpenGL.
  struct Message
    extend ErrorHandling

    # Retrieves the maximum length allowed for the `#message` string.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_MAX_DEBUG_MESSAGE_LENGTH, &value)
    # ```
    #
    # Minimum required version: 4.3
    def self.max_size
      # For some reason this isn't under `LibGL::GetPName`.
      pname = LibGL::GetPName.new(LibGL::MAX_DEBUG_MESSAGE_LENGTH.to_u32)
      checked do
        LibGL.get_integer_v(pname, out length)
        length
      end
    end

    # Source that produced the message.
    getter source : Source

    # Type of message.
    getter type : Type

    # Message ID.
    getter id : UInt32

    # Importance of the message.
    getter severity : Severity

    # Text in the message.
    getter message : String

    # Builds a message with the raw data received from OpenGL.
    protected def initialize(source, type, @id, severity, length, string)
      @source = Source.from_value(source)
      @type = Type.from_value(source)
      @severity = Severity.from_value(severity)
      @message = String.new(string, length)
    end

    # Produces a log-like string from the contents of the debug message.
    def to_s(io)
      io.printf("%7s [%s:%s] (%d) %s", severity, source, type, id, message)
    end
  end
end
