module Gloop
  struct Debug
    # Debug message sources.
    enum Type : LibGL::Enum
      # Used for filtering messages.
      DontCare = LibGL::DebugType::DontCare

      # An error occurred.
      Error = LibGL::DebugType::DebugTypeError

      # Behavior marked as deprecated has been used.
      DeprecatedBehavior = LibGL::DebugType::DebugTypeDeprecatedBehavior

      # Something invoked undefined behavior.
      UndefinedBehavior = LibGL::DebugType::DebugTypeUndefinedBehavior

      # Non-portable functionality has been used.
      Portability = LibGL::DebugType::DebugTypePortability

      # Possible non-performant code has been detected.
      Performance = LibGL::DebugType::DebugTypePerformance

      # Command stream annotation.
      Marker = LibGL::DebugType::DebugTypeMarker

      # Debug group has been pushed.
      PushGroup = LibGL::DebugType::DebugTypePushGroup

      # Debug group has been popped.
      PopGroup = LibGL::DebugType::DebugTypePopGroup

      # None of the above.
      Other = LibGL::DebugType::DebugTypeOther

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::DebugType.new(value)
      end
    end
  end
end
