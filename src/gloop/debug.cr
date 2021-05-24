require "./debug/*"
require "./error_handling"

module Gloop
  # Methods for interacting with OpenGL's debugging features.
  module Debug
    extend self
    extend ErrorHandling

    # Storage for the debug message callback.
    # Necessary to prevent garbage collection on it.
    @@callback : Pointer(Void)?

    # Sets a callback to be invoked when OpenGL sends a debug message.
    # The block provided to this method will be called when a message is received.
    # This method returns immediately after the callback has been established.
    # Subsequent calls to this method will overwrite the previous callback.
    # Only one callback (the latest) will be invoked.
    # The block will be given a `Message` instance containing the debug message.
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
