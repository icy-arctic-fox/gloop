require "./error_handling"
require "./parameters"

module Gloop
  # Mix-in for OpenGL object types that support labels.
  # See: https://www.khronos.org/opengl/wiki/Debug_Output#Object_names
  #
  # Types including this module must define `#object_type` and `#name`.
  module Labelable
    extend ErrorHandling
    include ErrorHandling
    include Parameters

    # Enum value corresponding to the OpenGL object type.
    abstract def object_type

    # Name (identifier) OpenGL uses to reference the object.
    abstract def name

    # Retrieves the maximum length allowed for a label.
    #
    # Effectively calls:
    # ```c
    # glGetIntegerv(GL_MAX_LABEL_LENGTH, &value)
    # ```
    #
    # Minimum required version: 4.3
    class_parameter MaxLabelLength, max_label_size : Int32

    # Attempts to retrieve the label set for this object.
    # If there is no label, an empty string is returned.
    #
    # Effectively calls:
    # ```c
    # glGetObjectLabel(object_type, name, sizeof(buffer), &length, buffer)
    # ```
    #
    # Minimum required version: 4.3
    def label : String
      buffer_size = Labelable.max_label_size

      String.new(buffer_size) do |buffer|
        checked do
          LibGL.get_object_label(object_type, name, buffer_size, out length, buffer)
          {length, 0}
        end
      end
    end

    # Sets the label for this object.
    # The *label* will be stringified before it is stored.
    #
    # Effectively calls:
    # ```c
    # glObjectLabel(object_type, name, label.bytesize, label)
    # ```
    #
    # Minimum required version: 4.3
    def label=(label)
      string = label.to_s
      checked { LibGL.object_label(object_type, name, string.bytesize, string) }
    end

    # Removes any previously set label for this object.
    #
    # Effectively calls:
    # ```c
    # glObjectLabel(object_type, name, 0, NULL)
    # ```
    #
    # Minimum required version: 4.3
    def label=(label : Nil)
      checked { LibGL.object_label(object_type, name, 0, nil) }
    end
  end
end
