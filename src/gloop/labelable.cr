require "opengl"
require "./error_handling"

module Gloop
  # Mix-in for OpenGL types that support labeling.
  # Labels are a way to help debug objects.
  #
  # Including types must implement the `#object_identifier` method.
  # The object "name" (OpenGL ID) is retrieved from the `#to_unsafe` method.
  module Labelable
    include ErrorHandling

    # Maximum length a label can be.
    def self.max_label_size
      ErrorHandling.static_checked do
        LibGL.get_integer_v(LibGL::GetPName::MaxLabelLength, out result)
        result
      end
    end

    # Retrieves the label of the object.
    def label
      capacity = Labelable.max_label_size
      String.new(capacity) do |buffer|
        byte_size = checked do
          LibGL.get_object_label(object_identifier, self, capacity, out length, buffer)
          length
        end
        # Don't subtract one here because OpenGL provides the length without the null-terminator.
        {byte_size, 0}
      end
    end

    # Sets the label of the object.
    def label=(string)
      checked do
        LibGL.object_label(object_identifier, self, string.bytesize, string)
      end
    end

    # Removes any previously set label.
    def remove_label
      checked do
        LibGL.object_label(object_identifier, self, 0, nil)
      end
    end

    # Namespace from which the name of the object is allocated.
    private abstract def object_identifier : LibGL::ObjectIdentifier
  end
end
