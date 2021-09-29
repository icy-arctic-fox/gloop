require "../contextual"
require "../parameters"
require "./message"

module Gloop
  struct Debug
    # Iterates through messages in the debug log.
    #
    # Once a message is retrieved, it is removed from the log.
    struct MessageIterator
      include Contextual
      include Iterator(Message)
      include Parameters

      # Retrieves the size of the next logged message in bytes.
      #
      # Returns nil if the message log is empty.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `GL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH`
      # - OpenGL version: 4.3
      @[GLFunction("glGetIntegerv", enum: "GL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH", version: "4.3")]
      private parameter(LibGL::DEBUG_NEXT_LOGGED_MESSAGE_LENGTH, next_message_size) do |value|
        return (value - 1) unless value.zero?
      end

      # Retrieves the maximum number of bytes a log message can have.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `MAX_DEBUG_MESSAGE_LENGTH`
      # - OpenGL version: 4.3
      @[GLFunction("glGetIntegerv", enum: "MAX_DEBUG_MESSAGE_LENGTH", version: "4.3")]
      parameter LibGL::MAX_DEBUG_MESSAGE_LENGTH, max_message_size : Int32

      # Number of messages pending retrieval in the debug message log.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `GL_DEBUG_LOGGED_MESSAGES`
      # - OpenGL version: 4.3
      @[GLFunction("glGetIntegerv", enum: "GL_DEBUG_LOGGED_MESSAGES", version: "4.3")]
      parameter LibGL::DEBUG_LOGGED_MESSAGES, size

      # Retrieves the maximum number of debug messages thte log can hold.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `GL_MAX_DEBUG_LOGGED_MESSAGES`
      # - OpenGL version: 4.3
      @[GLFunction("glGetIntegerv", enum: "GL_MAX_DEBUG_LOGGED_MESSAGES", version: "4.3")]
      parameter LibGL::MAX_DEBUG_LOGGED_MESSAGES, max : Int32

      # Checks if there are no debug messages in the log.
      def empty?
        size.zero?
      end

      # Retrieves the next message in the log or returns a stop instance.
      #
      # - OpenGL functions: `glGetDebugMessageLog`
      # - OpenGL version: 4.3
      @[GLFunction("glGetDebugMessageLog", version: "4.3")]
      def next
        source = uninitialized LibGL::DebugSource
        type = uninitialized LibGL::DebugType
        id = uninitialized UInt32
        severity = uninitialized LibGL::DebugSeverity

        message = string_query(next_message_size, null_terminator: true) do |buffer, capacity, length|
          count = gl.get_debug_message_log(1_u32, capacity, pointerof(source), pointerof(type),
            pointerof(id), pointerof(severity), length, buffer)
          return stop if count.zero? # No messages retrieved.
        end
        return stop unless message # No messages retrieved.

        Message.new(source, type, id, severity, message)
      end

      # Retrieves the first *n* messages from the debug log as an array.
      #
      # - OpenGL functions: `glGetDebugMessageLog`
      # - OpenGL version: 4.3
      @[GLFunction("glGetDebugMessageLog", version: "4.3")]
      def first(n : Int)
        raise ArgumentError.new "Attempted to take negative size: #{n}" if n < 0

        sources = Pointer(LibGL::DebugSource).malloc(n)
        types = Pointer(LibGL::DebugType).malloc(n)
        ids = Pointer(UInt32).malloc(n)
        severities = Pointer(LibGL::DebugSeverity).malloc(n)
        lengths = Pointer(Int32).malloc(n)
        buffer_size = max_message_size * n
        buffer = Pointer(UInt8).malloc(buffer_size)

        count = gl.get_debug_message_log(n.to_u32, buffer_size, sources, types, ids, severities, lengths, buffer)
        offset = 0
        Array.new(count) do |i|
          length = lengths[i]
          message = Message.new(sources[i], types[i], ids[i], severities[i], length - 1, buffer + offset)
          offset += length
          message
        end
      end

      # Skips the next *n* messages in the log.
      #
      # - OpenGL functions: `glGetDebugMessageLog`
      # - OpenGL version: 4.3
      @[GLFunction("glGetDebugMessageLog", version: "4.3")]
      def skip(n : Int)
        raise ArgumentError.new "Attempted to skip negative size: #{n}" if n < 0

        n.times { break unless skip } # Bail early if the log is empty.
        self                          # Return self to match `Iterator#skip`.
      end

      # Skips the next message in the log.
      #
      # Returns true if a message was skipped, false if the log is empty.
      #
      # - OpenGL functions: `glGetDebugMessageLog`
      # - OpenGL version: 4.3
      @[GLFunction("glGetDebugMessageLog", version: "4.3")]
      def skip : Bool
        source = Pointer(LibGL::DebugSource).null
        type = Pointer(LibGL::DebugType).null
        id = Pointer(UInt32).null
        severity = Pointer(LibGL::DebugSeverity).null
        length = Pointer(Int32).null
        buffer = Pointer(UInt8).null

        count = gl.get_debug_message_log(1_u32, 0, source, type, id, severity, length, buffer)
        !count.zero?
      end

      # Removes all pending debug messages from the log.
      def clear
        loop { break unless skip }
      end

      # Retrieves all messages from the debug log as an array.
      def to_a
        first(size)
      end
    end
  end
end
