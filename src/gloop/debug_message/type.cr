require "opengl"

module Gloop
  struct DebugMessage
    # Message type.
    enum Type : UInt32
      Unknown = LibGL::DebugType::DontCare

      Error = LibGL::DebugType::DebugTypeError

      DeprecatedBehavior = LibGL::DebugType::DebugTypeDeprecatedBehavior

      UndefinedBehavior = LibGL::DebugType::DebugTypeUndefinedBehavior

      Portability = LibGL::DebugType::DebugTypePortability

      Performance = LibGL::DebugType::DebugTypePerformance

      Other = LibGL::DebugType::DebugTypeOther

      Marker = LibGL::DebugType::DebugTypeMarker

      PushGroup = LibGL::DebugType::DebugTypePushGroup

      PopGroup = LibGL::DebugType::DebugTypePopGroup
    end
  end
end
