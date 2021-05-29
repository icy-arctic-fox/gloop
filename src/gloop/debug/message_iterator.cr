require "../error_handling"
require "./message"

module Gloop::Debug
  # Iterates through messages in the debug log.
  struct MessageIterator
    include ErrorHandling
    include Iterator(Message)

    # Retrieves the next message in the log or returns a stop instance.
    def next
      source = uninitialized LibGL::DebugSource
      type = uninitialized LibGL::DebugType
      id = uninitialized UInt32
      severity = uninitialized LibGL::DebugSeverity

      buffer_size = next_message_size
      message = String.new(buffer_size) do |buffer|
        length = uninitialized Int32
        count = expect_truthy do
          LibGL.get_debug_message_log(1, buffer_size, pointerof(source), pointerof(type), pointerof(id), pointerof(severity), pointerof(length), buffer)
        end
        return stop if count.zero?

        {length - 1, 0}
      end

      Message.new(
        Source.from_value(source.to_u32),
        Type.from_value(type.to_u32),
        id,
        Severity.from_value(severity.to_u32),
        message
      )
    end

    # Size of the next log message string in bytes.
    # This includes the null-terminator.
    private def next_message_size
      pname = LibGL::GetPName.new(LibGL::DEBUG_NEXT_LOGGED_MESSAGE_LENGTH.to_u32)
      checked do
        LibGL.get_integer_v(pname, out value)
        value
      end
    end
  end
end
