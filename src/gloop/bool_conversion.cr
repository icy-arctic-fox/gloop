require "opengl"

module Gloop
  # Mix-in for converting between Crystal booleans and OpenGL integer booleans.
  private module BoolConversion
    # Checks whether an integer is a truthy value.
    # The *value* argument can be a `LibGL::Boolean` or integer.
    # Returns true if *value* is not `LibGL::Boolean::False` or zero.
    private def int_to_bool(value)
      value.to_i != LibGL::Boolean::False.to_i
    end

    # Converts a native Crystal boolean to an integer OpenGL expects.
    # True is returned if *value* is truthy (not false or nil).
    private def bool_to_int(value)
      value ? LibGL::Boolean::True : LibGL::Boolean::False
    end
  end
end
