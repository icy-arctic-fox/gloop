require "./debug/*"
require "./error_handling"

module Gloop
  # Methods for interacting with OpenGL's debugging features.
  module Debug
    extend self
    extend ErrorHandling

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
    def on_message(&block : Message -> _) : Nil
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
  end
end
