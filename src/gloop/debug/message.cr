require "./severity"
require "./source"
require "./type"

module Gloop
  struct Debug
    # Debug information received from OpenGL.
    struct Message
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
      protected def initialize(source : LibGL::DebugSource | UInt32, type : LibGL::DebugType | UInt32,
                               @id : UInt32, severity : LibGL::DebugSeverity | UInt32, @message : String)
        @source = Source.from_value(source.to_u32!)
        @type = Type.from_value(type.to_u32!)
        @severity = Severity.from_value(severity.to_u32!)
      end

      # Builds a message with the raw data received from OpenGL.
      protected def initialize(source, type, id, severity, length : Int, string : UInt8*)
        message = String.new(string, length)
        initialize(source, type, id, severity, message)
      end

      # Inserts this debug message into the specified context.
      #
      # - OpenGL function: `glDebugMessageInsert`
      # - OpenGL version: 4.3
      @[GLFunction("glDebugMessageInsert", version: "4.3")]
      def insert(context)
        context.gl.debug_message_insert(
          @source.to_unsafe,
          @type.to_unsafe,
          @id,
          @severity.to_unsafe,
          @message.bytesize,
          @message.to_unsafe
        )
      end

      # Produces a log-like string from the contents of the debug message.
      def to_s(io)
        io.printf("%7s [%s:%s] (%d) %s", severity, source, type, id, message)
      end
    end
  end
end
