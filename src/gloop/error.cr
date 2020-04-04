require "opengl"
require "./error_factory"

module Gloop
  # Retrieves the currently reported OpenGL error.
  # Returns an instance of `OpenGLError`, but does not raise it.
  # If no error has occurred, then nil is returned.
  #
  # If consecutive errors occur,
  # the first error is kept and not overwritten.
  # This means consecutive errors will be lost.
  # This method should be checked immediately
  # after interacting with OpenGL when an error might occur.
  # After this method is called, the error will be cleared.
  def self.error
    code = LibGL.get_error
    ErrorFactory.new.build(code)
  end

  # Checks if there was an error from OpenGL.
  # If there was an error, then it is raised.
  # Othwerise, this method returns nothing.
  #
  # If consecutive errors occur,
  # the first error is kept and not overwritten.
  # This means consecutive errors will be lost.
  # This method should be checked immediately
  # after interacting with OpenGL when an error might occur.
  # After this method is called, the error will be cleared.
  def self.error!
    if (e = error)
      raise e
    end
  end
end
