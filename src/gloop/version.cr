module Gloop
  # Captures version information with a major and minor component.
  record Version, major : Int32, minor : Int32 do
    # Produces a string containing the components.
    def to_s(io)
      io << major
      io << '.'
      io << minor
    end
  end
end
