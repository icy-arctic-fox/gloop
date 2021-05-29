require "./severity"
require "./source"
require "./type"

module Gloop::Debug
  # Debug information received from OpenGL.
  struct Message
    extend ErrorHandling
    include ErrorHandling

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

    # Creates a new message intended to be sent to the OpenGL debug message queue.
    # The *source* indicates where the message came from.
    # It should be `Source::Application` or `Source::ThirdParty`.
    def initialize(@source : Source, @type : Type, @id : UInt32, @severity : Severity, @message : String)
    end

    # Builds a message with the raw data received from OpenGL.
    protected def initialize(source, type, @id, severity, length, string)
      @source = Source.from_value(source.to_u32)
      @type = Type.from_value(type.to_u32)
      @severity = Severity.from_value(severity.to_u32)
      @message = String.new(string, length)
    end

    # Sends this debug message to OpenGL's debug message queue.
    #
    # Effectively calls:
    # ```c
    # glDebugMessageInsert(source, type, id, severity, length, message)
    # ```
    #
    # Minimum required version: 4.3
    def insert
      checked do
        LibGL.debug_message_insert(@source, @type, @id, @severity, @message.bytesize, @message)
      end
    end

    # Produces a log-like string from the contents of the debug message.
    def to_s(io)
      io.printf("%7s [%s:%s] (%d) %s", severity, source, type, id, message)
    end
  end
end
