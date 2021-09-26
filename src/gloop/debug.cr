require "./capabilities"
require "./contextual"
require "./debug/*"

module Gloop
  # Interacts with OpenGL's debugging features.
  struct Debug
    include Capabilities
    include Contextual

    self_capability DebugOutput, version: "4.3"
    capability DebugOutputSynchronous, sync, version: "4.3"

    # Sends a debug message to OpenGL's debug message queue.
    #
    # See: `Message#insert`
    def log(message, *,
            severity : Severity = :notification,
            type : Type = :other,
            source : Source = :application,
            id : UInt32 = 0) : Nil
      message = Message.new(source, type, id, severity, message.to_s)
      insert(message)
    end

    # Sends a debug message to OpenGL's debug message queue.
    #
    # See: `Message#insert`
    @[AlwaysInline]
    def insert(message) : Nil
      message.insert(context)
    end

    # Pushes a debug group onto the stack.
    #
    # - OpenGL function: `glPushDebugGroup`
    # - OpenGL version: 4.3
    @[GLFunction("glPushDebugGroup", version: "4.3")]
    def push(message, source : Source = :application, id : UInt32 = 0)
      message = message.to_s
      gl.push_debug_group(source.to_unsafe, id, message.bytesize, message.to_unsafe)
    end

    # Pops a debug group off of the stack.
    #
    # - OpenGL function: `glPopDebugGroup`
    # - OpenGL version: 4.3
    @[GLFunction("glPopDebugGroup", version: "4.3")]
    def pop
      gl.pop_debug_group
    end

    # Pushes a debug group onto the stack and yields.
    # Pops the debug group after the block returns.
    #
    # See: `#push`, `#pop`
    def group(message, source : Source = :application, id : UInt32 = 0)
      push(message, source, id)
      begin
        yield
      ensure
        pop
      end
    end

    # Provides access to all pending debug messages in the queue.
    def messages
      # TODO
    end

    # Removes all pending debug messages from the queue.
    def clear
      # TODO
    end

    # Specifies debug messages to receive.
    # Messages can be allowed by specifying any combination of *source*, *type*, and *severity* flags.
    #
    # See: `#reject`
    #
    # - OpenGL function: `glDebugMessageControl`
    # - OpenGL version: 4.3
    @[GLFunction("glDebugMessageControl", version: "4.3")]
    def allow(*, source : Source = :dont_care, type : Type = :dont_care, severity : Severity = :dont_care)
      gl.debug_message_control(
        source.to_unsafe,
        type.to_unsafe,
        severity.to_unsafe,
        0,                    # Message IDs length.
        Pointer(UInt32).null, # Message IDs list.
        LibGL::Boolean::True
      )
    end

    # Specifies IDs of debug messages to receive.
    # Messages can be allowed by specifying any combination of *source* and *type* flags.
    #
    # NOTE: Severity cannot be set with this method.
    #
    # See: `#reject`
    #
    # - OpenGL function: `glDebugMessageControl`
    # - OpenGL version: 4.3
    @[GLFunction("glDebugMessageControl", version: "4.3")]
    def allow(ids : Indexable(UInt32), *, source : Source = :dont_care, type : Type = :dont_care)
      # Some indexable types allow unsafe direct access to their internals.
      # Use that if it's available, as it is much faster.
      # Otherwise, convert to an array, which allows direct access via `#to_unsafe`.
      ids = ids.to_a unless ids.responds_to?(:to_unsafe)

      gl.debug_message_control(
        source.to_unsafe,
        type.to_unsafe,
        LibGL::DebugSeverity::DontCare, # Must be `DontCare` when specifying ID list.
        ids.size,
        ids.to_unsafe,
        LibGL::Boolean::True
      )
    end

    # Specifies debug messages to ignore.
    # Messages can be ignored by specifying any combination of *source*, *type*, and *severity* flags.
    #
    # See: `#reject`
    #
    # - OpenGL function: `glDebugMessageControl`
    # - OpenGL version: 4.3
    @[GLFunction("glDebugMessageControl", version: "4.3")]
    def reject(*, source : Source = :dont_care, type : Type = :dont_care, severity : Severity = :dont_care)
      gl.debug_message_control(
        source.to_unsafe,
        type.to_unsafe,
        severity.to_unsafe,
        0,                    # Message IDs length.
        Pointer(UInt32).null, # Message IDs list.
        LibGL::Boolean::False
      )
    end

    # Specifies IDs of debug messages to ignore.
    # Messages can be ignored by specifying any combination of *source* and *type* flags.
    #
    # NOTE: Severity cannot be set with this method.
    #
    # See: `#reject`
    #
    # - OpenGL function: `glDebugMessageControl`
    # - OpenGL version: 4.3
    @[GLFunction("glDebugMessageControl", version: "4.3")]
    def reject(ids : Indexable(UInt32), *, source : Source = :dont_care, type : Type = :dont_care)
      # Some indexable types allow unsafe direct access to their internals.
      # Use that if it's available, as it is much faster.
      # Otherwise, convert to an array, which allows direct access via `#to_unsafe`.
      ids = ids.to_a unless ids.responds_to?(:to_unsafe)

      gl.debug_message_control(
        source.to_unsafe,
        type.to_unsafe,
        LibGL::DebugSeverity::DontCare, # Must be `DontCare` when specifying ID list.
        ids.size,
        ids.to_unsafe,
        LibGL::Boolean::False
      )
    end

    # Storage for the debug message callback.
    # Necessary to prevent garbage collection on it.
    private context_storage message_callback : Void*

    # Sets a callback to be invoked when OpenGL sends a debug message.
    # The block provided to this method will be called when a message is received.
    # This method returns immediately after the callback has been established.
    # Subsequent calls to this method will overwrite the previous callback.
    # Only one callback (the latest) will be invoked.
    # The block will be given a `Message` instance containing the debug message as an argument.
    #
    # - OpenGL function: `glDebugMessageCallback`
    # - OpenGL version: 4.3
    @[GLFunction("glDebugMessageCallback", version: "4.3")]
    def on_message(&block : Message ->) : Nil
      # Pack up the client's callback and store.
      # The callback is passed as the user param.
      # Storing it prevents it from being garbage collected.
      # Calling this method a second time will replace the first callback, allowing it to be garbage collected.
      callback = Box.box(block)
      self.message_callback = callback

      # Create the proc given to OpenGL.
      # The proc gathers the message attributes and invokes the client's callback.
      # This cannot be a closure.
      proc = LibGL::DebugProc.new do |source, type, id, severity, length, string, user_param|
        # Collect all message fields.
        message = Message.new(source, type, id, severity, length, string)

        # Unlikely, but ensure `user_param` isn't null before unpacking.
        next if user_param.null?

        # Unpack the client's callback and call it.
        unboxed = Box(typeof(block)).unbox(user_param)
        unboxed.call(message)
      end

      # Set the callback to the proc and pass along the boxed callback for `user_param`.
      gl.debug_message_callback(proc.pointer, callback)
    end

    # Clears a previously set callback.
    # This effectively undoes `#on_message`.
    #
    # It is recommended to call this method before cleaning up the OpenGL context.
    #
    # - OpenGL function: `glDebugMessageCallback`
    # - OpenGL version: 4.3
    @[GLFunction("glDebugMessageCallback", version: "4.3")]
    def clear_on_message
      null = Pointer(Void).null
      self.message_callback = null
      gl.debug_message_callback(null, null)
    end
  end

  struct Context
    # Provides access to debug functionality for this context.
    def debug : Debug
      Debug.new(self)
    end
  end
end
