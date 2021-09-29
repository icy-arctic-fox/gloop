module Gloop
  # Integer type used for size-related operations.
  #
  # OpenGL functions will use 32-bit or 64-bit integers depending on the system architecture.
  {% if flag?(:x86_64) %}
    alias Size = Int64
  {% else %}
    alias Size = Int32
  {% end %}
end
