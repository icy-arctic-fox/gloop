# Include setup and teardown methods for the specified library.
{% if flag?(:sdl) %}
  require "./helpers/sdl"
{% else %}
  require "./helpers/glfw"
{% end %}

require "spectator"
require "../src/gloop"

# Workaround for storing a single context in the global scope.
CONTEXT_WRAPPER = [] of Gloop::Context

# Shared context used for all tests.
def context
  CONTEXT_WRAPPER[0]? || raise("Context not created")
end

macro skip_if_error_checking_disabled
  {% if flag?(:release) && !flag?(:error_checking) %}
    skip "Error checking disabled, compile with -Derror_checking to enable."
  {% end %}
end

Spectator.configure do |config|
  config.before_suite do
    init_opengl
    CONTEXT_WRAPPER << create_context
  end

  config.after_suite { terminate_opengl }
end
