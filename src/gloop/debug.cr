require "./capabilities"
require "./debug/*"
require "./error_handling"

module Gloop
  # Methods for interacting with OpenGL's debugging features.
  module Debug
    extend self
    extend ErrorHandling
    include Capabilities

    capability DebugOutputSynchronous, sync

    # Retrieves the number of debug messages in queue.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_DEBUG_LOGGED_MESSAGES, &value)
    # ```
    #
    # Minimum required version: 4.3
    def message_count : Int32
      pname = LibGL::GetPName.new(LibGL::DEBUG_LOGGED_MESSAGES.to_u32)
      checked do
        LibGL.get_integer_v(pname, out value)
        value
      end
    end

    # Retrieves the maximum number of debug messages the queue can hold.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_MAX_DEBUG_LOGGED_MESSAGES, &value)
    # ```
    #
    # Minimum required version: 4.3
    def max_message_count : Int32
      pname = LibGL::GetPName.new(LibGL::MAX_DEBUG_LOGGED_MESSAGES.to_u32)
      checked do
        LibGL.get_integer_v(pname, out value)
        value
      end
    end

    # Enables debug output functionality.
    #
    # Effectively calls:
    # ```c
    # glEnable(GL_DEBUG_OUTPUT)
    # ```
    #
    # Minimum required version: 4.3
    def enable
      checked { LibGL.enable(LibGL::EnableCap::DebugOutput) }
    end

    # Disables debug output functionality.
    #
    # Effectively calls:
    # ```c
    # glDisable(GL_DEBUG_OUTPUT)
    # ```
    #
    # Minimum required version: 4.3
    def disable
      checked { LibGL.disable(LibGL::EnableCap::DebugOutput) }
    end

    # Enables or disables debug output functionality.
    # If *flag* is true, the capability will be enabled.
    # Otherwise, the capability will be disabled.
    #
    # Minimum required version: 4.3
    def enabled=(flag)
      if flag
        enable
      else
        disable
      end
    end

    # Checks if debug output functionality is enabled.
    #
    # Effectively calls:
    # ```c
    # glIsEnabled(GL_DEBUG_OUTPUT)
    # ```
    #
    # Minimum required version: 4.3
    def enabled?
      checked do
        value = LibGL.is_enabled(LibGL::EnableCap::DebugOutput)
        !value.false?
      end
    end

    # Sends a debug message to OpenGL's debug message queue.
    # This method takes a block, which returns the message text.
    #
    # ```
    # Gloop::Debug.log(:low, type: :performance) { "Shader program swapped repeatedly - possible performance loss." }
    # ```
    def log(severity : Severity, *, type : Type = :other, source : Source = :application, id : UInt32 = 0) : Nil
      message = yield.to_s
      message = Message.new(source, type, id, severity, message)
      message.insert
    end

    # Sends a debug message to OpenGL's debug message queue.
    # See: `Message#insert`
    def insert(message : Message)
      message.insert
    end

    # Specifies debug messages to receive.
    # Messages can be allowed by specifying any combination
    # of *source*, *type*, and *severity* flags.
    # Additionally, if specific IDs of messages can be allowed
    # by specifying them in the *ids* array.
    #
    # See: `.reject`
    #
    # Effectively calls:
    # ```c
    # glDebugMessageControl(source, type, severity, 0, NULL, GL_TRUE)
    # ```
    #
    # Minimum required version: 4.3
    def allow(*, source : Source = :dont_care, type : Type = :dont_care, severity : Severity = :dont_care)
      checked { LibGL.debug_message_control(source, type, severity, 0, nil, LibGL::Boolean::True) }
    end

    # Specifies debug messages to receive.
    # Messages can be allowed by specifying any combination
    # of *source*, *type*, and *severity* flags.
    # Additionally, if specific IDs of messages can be allowed
    # by specifying them in the *ids* array.
    #
    # See: `.reject`
    #
    # Effectively calls:
    # ```c
    # glDebugMessageControl(source, type, GL_DONT_CARE, count, ids, GL_TRUE)
    # ```
    #
    # Minimum required version: 4.3
    def allow(*, ids : Indexable(UInt32), source : Source = :dont_care, type : Type = :dont_care)
      checked { LibGL.debug_message_control(source, type, LibGL::DebugSeverity::DontCare, ids.size, ids, LibGL::Boolean::True) }
    end

    # Specifies debug messages to ignore.
    # Messages can be ignored by specifying any combination
    # of *source*, *type*, and *severity* flags.
    # Additionally, if specific IDs of messages can be ignored
    # by specifying them in the *ids* array.
    #
    # See: `.accept`
    #
    # Effectively calls:
    # ```c
    # glDebugMessageControl(source, type, severity, count ids, GL_FALSE)
    # ```
    #
    # Minimum required version: 4.3
    def reject(*, source : Source = :dont_care, type : Type = :dont_care, severity : Severity = :dont_care)
      checked { LibGL.debug_message_control(source, type, severity, 0, nil, LibGL::Boolean::False) }
    end

    # Specifies debug messages to ignore.
    # Messages can be ignored by specifying any combination
    # of *source*, *type*, and *severity* flags.
    # Additionally, if specific IDs of messages can be ignored
    # by specifying them in the *ids* array.
    #
    # See: `.accept`
    #
    # Effectively calls:
    # ```c
    # glDebugMessageControl(source, type, severity, count ids, GL_FALSE)
    # ```
    #
    # Minimum required version: 4.3
    def reject(*, ids : Indexable(UInt32), source : Source = :dont_care, type : Type = :dont_care)
      checked { LibGL.debug_message_control(source, type, LibGL::DebugSeverity::DontCare, ids.size, ids, LibGL::Boolean::False) }
    end

    # Pushes a debug group onto the stack.
    #
    # Effectively calls:
    # ```c
    # glPushDebugGroup(source, id, length, message)
    # ```
    #
    # Minimum required version: 4.3
    def push_group(message, source : Source = :application, id = 0_u32)
      checked { LibGL.push_debug_group(source, id, message.bytesize, message) }
    end

    # Pops a debug group off of the stack.
    #
    # Effectively calls:
    # ```c
    # glPopDebugGroup
    # ```
    #
    # Minimum required version: 4.3
    def pop_group
      checked { LibGL.pop_debug_group }
    end

    # Pushes a debug group onto the stack and yields.
    # Pops the debug group after the block completes.
    #
    # See: `.push_group`, `.pop_group`
    def group(message, source : Source = :application, id = 0_u32)
      push_group(message, source, id)
      begin
        yield
      ensure
        pop_group
      end
    end

    # Retrieves all available messages from the debug log.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_DEBUG_LOGGED_MESSAGES, &count);
    # glGetDebugMessageLog(count, buffer_size, &sources, &types, &ids, &severities, &lengths, &messageLog);
    # ```
    #
    # Minimum required version: 4.3
    def messages
      messages(message_count)
    end

    # Retrieves the first available message from the debug log.
    # At most *count* are retrieved.
    #
    # Effectively calls:
    # ```c
    # glGetDebugMessageLog(count, buffer_size, &sources, &types, &ids, &severities, &lengths, &messageLog);
    # ```
    #
    # Minimum required version: 4.3
    def messages(count)
      return [] of Message if count < 1

      attributes = message_attribute_pointers(count)

      buffer_size = count * Message.max_size
      buffer = Pointer(UInt8).malloc(buffer_size)
      count = expect_truthy do
        LibGL.get_debug_message_log(count, buffer_size, *attributes, buffer)
      end

      extract_messages(count, buffer, *attributes)
    end

    # Allocates memory for *count* number of messages with their attributes in parallel arrays.
    # Returns the pointers of each attribute array.
    private def message_attribute_pointers(count)
      sources = Pointer(LibGL::DebugSource).malloc(count)
      types = Pointer(LibGL::DebugType).malloc(count)
      ids = Pointer(UInt32).malloc(count)
      severities = Pointer(LibGL::DebugSeverity).malloc(count)
      lengths = Pointer(Int32).malloc(count)

      {sources, types, ids, severities, lengths}
    end

    # Constructs messages from their attributes and a buffer containing log text.
    private def extract_messages(count, buffer, *attributes)
      sources, types, ids, severities, lengths = attributes

      offset = 0
      Array.new(count) do |i|
        length = lengths[i]
        message = Message.new(sources[i], types[i], ids[i], severities[i], length - 1, buffer + offset)
        offset += length
        message
      end
    end

    # Storage for the debug message callback.
    # Necessary to prevent garbage collection on it.
    @@callback : Pointer(Void)?

    # Sets a callback to be invoked when OpenGL sends a debug message.
    # The block provided to this method will be called when a message is received.
    # This method returns immediately after the callback has been established.
    # Subsequent calls to this method will overwrite the previous callback.
    # Only one callback (the latest) will be invoked.
    # The block will be given a `Message` instance containing the debug message.
    #
    # Effectively calls:
    # ```c
    # glDebugMessageCallback(callback, user_param)
    # ```
    #
    # Minimum required version: 4.3
    def on_message(&block : Message ->) : Nil
      # Pack up the client's callback and store.
      # The callback is passed as the user param.
      # Storing it in a class variable prevents it from being garbage collected.
      # Calling this method a second time will replace the first callback, allowing it to be garbage collected.
      callback = Box.box(block)
      @@callback = callback

      checked do
        # Set the callback to a proc that will unpack the block with the correct type.
        LibGL.debug_message_callback(->(source, type, id, severity, length, string, user_param) {
          # Collect all fields into a single structure.
          message = Message.new(source, type, id, severity, length, string)

          # Unpack the client's callback and call it.
          unboxed = Box(typeof(block)).unbox(user_param)
          unboxed.call(message)
        }, callback)
      end
    end

    # Removes the callback that is invoked when OpenGL sends a debug message.
    #
    # Effectively calls:
    # ```c
    # glDebugMessageCallback(NULL, NULL)
    # ```
    #
    # Minimum required version: 4.3
    def clear_message_listener
      @@callback = nil
      checked { LibGL.debug_message_callback(nil, nil) }
    end
  end
end
