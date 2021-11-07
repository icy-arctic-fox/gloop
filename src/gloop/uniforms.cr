require "./contextual"
require "./uniform_location"

module Gloop
  # Access to uniforms from the program currently in use.
  #
  # NOTE: If the active program is changed,
  #   existing references to uniforms will change to the new program,
  #   which may not exist.
  struct Uniforms
    include Contextual

    # References a uniform in the current program by its location.
    def [](location : Int32) : UniformLocation
      UniformLocation.new(@context, location)
    end
  end

  struct Context
    # References uniforms for the active program.
    def uniforms : Uniforms
      Uniforms.new(self)
    end
  end
end
