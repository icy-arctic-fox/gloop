require "opengl"

module Gloop
  struct DebugMessage
    # Message importance level.
    enum Severity : UInt32
      Unknown = LibGL::DebugSeverity::DontCare

      High = LibGL::DebugSeverity::DebugSeverityHigh

      Medium = LibGL::DebugSeverity::DebugSeverityMedium

      Low = LibGL::DebugSeverity::DebugSeverityLow

      Info = LibGL::DebugSeverity::DebugSeverityNotification
    end
  end
end
