module Gloop
  abstract struct Shader < Object
    # Range and precision information for types used in shaders.
    struct Precision
      # Minimum value that can be represented by the type.
      # This is represented as the number of bits (or base-2 exponent).
      # For instance, a value of 32 means it has a minimum value of (-2)^32.
      getter min : Int32

      # Maximum value that can be represented by the type.
      # This is represented as the number of bits (or base-2 exponent).
      # For instance, a value of 32 means it has a minimum value of 2^32.
      getter max : Int32

      # Number of bits of precision that can be represented by the type.
      getter precision : Int32

      # Creates the range and precision information.
      def initialize(@min, @max, @precision)
      end
    end

    # Mix-in for shader types that support precision methods.
    module PrecisionMethods
      # Precision that the shader support for small floating-point numbers.
      #
      # Effectively calls:
      # ```c
      # glGetShaderPrecisionFormat(shader_type, GL_LOW_FLOAT, range, &precision)
      # ```
      #
      # Minimum required version: 4.1
      def low_float_precision
        precision_format(LibGL::PrecisionType::LowFloat)
      end

      # Precision that the shader support for medium floating-point numbers.
      #
      # Effectively calls:
      # ```c
      # glGetShaderPrecisionFormat(shader_type, GL_MEDIUM_FLOAT, range, &precision)
      # ```
      #
      # Minimum required version: 4.1
      def medium_float_precision
        precision_format(LibGL::PrecisionType::MediumFloat)
      end

      # Precision that the shader support for large floating-point numbers.
      #
      # Effectively calls:
      # ```c
      # glGetShaderPrecisionFormat(shader_type, GL_HIGH_FLOAT, range, &precision)
      # ```
      #
      # Minimum required version: 4.1
      def high_float_precision
        precision_format(LibGL::PrecisionType::HighFloat)
      end

      # Precision that the shader support for small integers.
      #
      # Effectively calls:
      # ```c
      # glGetShaderPrecisionFormat(shader_type, GL_LOW_INT, range, &precision)
      # ```
      #
      # Minimum required version: 4.1
      def low_int_precision
        precision_format(LibGL::PrecisionType::LowInt)
      end

      # Precision that the shader support for medium integers.
      #
      # Effectively calls:
      # ```c
      # glGetShaderPrecisionFormat(shader_type, GL_MEDIUM_INT, range, &precision)
      # ```
      #
      # Minimum required version: 4.1
      def medium_int_precision
        precision_format(LibGL::PrecisionType::MediumInt)
      end

      # Precision that the shader support for large integers.
      #
      # Effectively calls:
      # ```c
      # glGetShaderPrecisionFormat(shader_type, GL_HIGH_INT, range, &precision)
      # ```
      #
      # Minimum required version: 4.1
      def high_int_precision
        precision_format(LibGL::PrecisionType::HighInt)
      end

      # Retrieves the specified precision type and converts it to a `Precision` instance.
      private def precision_format(precision_type)
        range = uninitialized Int32[2]
        precision = checked do
          LibGL.get_shader_precision_format(type, precision_type, range, out value)
          value
        end
        Precision.new(range[0], range[1], precision)
      end
    end
  end
end
