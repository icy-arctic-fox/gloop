module Gloop::Debug
  # Debug message severity (how important it is).
  enum Severity
    # Used for filtering messages.
    DontCare = LibGL::DebugSeverity::DontCare

    # OpenGL error, shader compilation and linking error, or highly-dangerous undefined behavior.
    High = LibGL::DebugSeverity::DebugSeverityHigh

    # Major performance warnings, shader compilation and linking warnings, or the use of deprecated functionality.
    Medium = LibGL::DebugSeverity::DebugSeverityMedium

    # Redundant state change performance warning or unimportant undefined behavior.
    Low = LibGL::DebugSeverity::DebugSeverityLow

    # Informational, not an error or performance issue.
    Notification = LibGL::DebugSeverity::DebugSeverityNotification
  end
end
