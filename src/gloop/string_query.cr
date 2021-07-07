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

      String.new(capacity) do |buffer|
        # Add 1 to capacity because `String.new` adds a byte for the null-terminator.
        length = checked { yield buffer, capacity + 1 }
        {length, 0}
      end
    end
  end
end
