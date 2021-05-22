require "./opengl_error"

module Gloop
  # OpenGL could not allocate more memory.
  #
  # This could be RAM or VRAM.
  # Virtually any OpenGL function could report this error.
  # OpenGL will be in an undefined state when this occurs.
  class OutOfMemoryError < OpenGLError
  end
end
