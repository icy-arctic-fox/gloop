module Gloop::Context
  # Features of an OpenGL context.
  @[Flags]
  enum Flags
    # The context is forward compatible.
    # Any features marked as deprecated in the version after this context's will be unavailable.
    ForwardCompatible = LibGL::ContextFlagMask::ContextFlagForwardCompatible

    # Additional information for developers is provided.
    Debug = LibGL::ContextFlagMask::ContextFlagDebug

    # Memory access is restricted to defined regions.
    # Attempting to access out-of-bounds memory will result in well-defined results.
    # Such accesses will never abnormally terminate the program or step on other processes.
    # Conflicts with `NoError`.
    RobustAccess = LibGL::ContextFlagMask::ContextFlagRobustAccess

    # All error handling is disabled.
    # No errors will be reported by OpenGL except for out-of-memory errors.
    # Conflicts with `RobustAccess`.
    NoError = LibGL::ContextFlagMask::ContextFlagNoError

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::ContextFlagMask.new(value)
    end
  end
end
