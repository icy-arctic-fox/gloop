require "opengl"
require "./debug_message/*"

module Gloop
  # Message from OpenGL which can be useful developers.
  struct DebugMessage
    # System the message came from.
    getter source : Source

    # Type of message.
    getter type : Type

    # Message important level.
    getter severity : Severity

    # ID of the message.
    getter id : UInt32

    # Message text.
    getter message : String

    # Creates the debug message.
    protected def initialize(@source, @type, @severity, @id, @message)
    end

    # Creates the debug message from values provided by OpenGL.
    protected def initialize(source, type, severity, @id, length, message)
      bytes = Bytes.new(message, length)
      @message = String.new(bytes)
      @source = Source.new(source)
      @type = Type.new(type)
      @severity = Severity.new(severity)
    end

    # Produces a string similar to a logger format containing the message.
    def to_s(io)
      io.printf("%7s [%s:%s] (%d) %s", severity, source, type, id, message)
    end
  end
end
