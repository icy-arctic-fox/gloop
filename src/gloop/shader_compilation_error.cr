module Gloop
  # An error occurred while attempting to compile a shader.
  class ShaderCompilationError < Exception
    # Information from the compilation process.
    getter info_log : String

    # Creates the error.
    # The first line from the log is used as the exception message.
    def initialize(@info_log)
      log_lines = @info_log.lines
      message = log_lines.size > 1 ? log_lines.first : @info_log
      super(message)
    end
  end
end
