module Gloop
  # Mix-in for wrapping string queries.
  # Simplifies the low-level processing of strings from OpenGL.
  private module StringQuery
    # Wrapper for fetching strings from OpenGL.
    # Accepts the maximum *capacity* for the string.
    # A new string will be allocated.
    # The buffer (pointer to the string contents) and capacity are yielded.
    # The block must call an OpenGL method to retrieve the string and return the final length.
    # The returned length must not include the null-terminator.
    # This method returns the string.
    private def string_query(capacity)
      return "" if capacity.zero?

      # Subtract one from capacity here because String adds a null-terminator.
      String.new(capacity - 1) do |buffer|
        length = checked { yield buffer, capacity }
        # Don't subtract one here because OpenGL provides the length without the null-terminator.
        {length, 0}
      end
    end
  end
end
