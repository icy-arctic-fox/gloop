module Gloop
  enum ImageFormatType
    # Normalized unsigned-integer.
    # Converted to a float between 0 and 1.
    UIntNorm

    # Normalized signed-integer.
    # Converted to a float between -1 and 1.
    IntNorm

    # Unsigned integer value.
    # Not converted to a float.
    UInt

    # Signed integer value.
    # Not converted to a float.
    Int

    # Floating-point value.
    Float
  end

  # Specifies number of components, bit-depth, and data type used for pixels.
  enum ImageFormat : UInt32
    UIntNormR   = LibGL::InternalFormat::Red
    UInt8NormR  = LibGL::InternalFormat::R8
    UInt16NormR = LibGL::InternalFormat::R16

    UIntNormRG   = LibGL::InternalFormat::RG
    UInt8NormRG  = LibGL::InternalFormat::RG8
    UInt16NormRG = LibGL::InternalFormat::RG16

    UIntNormRGB   = LibGL::InternalFormat::RGB
    UInt4NormRGB  = LibGL::InternalFormat::RGB4
    UInt5NormRGB  = LibGL::InternalFormat::RGB5
    UInt8NormRGB  = LibGL::InternalFormat::RGB8
    UInt10NormRGB = LibGL::InternalFormat::RGB10
    UInt12NormRGB = LibGL::InternalFormat::RGB12
    UInt16NormRGB = LibGL::InternalFormat::RGB16

    UIntNormRGBA   = LibGL::InternalFormat::RGBA
    UInt2NormRGBA  = LibGL::InternalFormat::RGBA2
    UInt4NormRGBA  = LibGL::InternalFormat::RGBA4
    UInt8NormRGBA  = LibGL::InternalFormat::RGBA8
    UInt12NormRGBA = LibGL::InternalFormat::RGBA12
    UInt16NormRGBA = LibGL::InternalFormat::RGBA16

    Int8NormR  = LibGL::InternalFormat::R8SNorm
    Int16NormR = LibGL::InternalFormat::R16SNorm

    Int8NormRG  = LibGL::InternalFormat::RG8SNorm
    Int16NormRG = LibGL::InternalFormat::RG16SNorm

    Int8NormRGB  = LibGL::InternalFormat::RGB8SNorm
    Int16NormRGB = LibGL::InternalFormat::RGB16SNorm

    Int8NormRGBA  = LibGL::InternalFormat::RGBA8SNorm
    Int16NormRGBA = LibGL::InternalFormat::RGBA16SNorm

    UInt8R  = LibGL::InternalFormat::R8UI
    UInt16R = LibGL::InternalFormat::R16UI
    UInt32R = LibGL::InternalFormat::R32UI

    UInt8RG  = LibGL::InternalFormat::RG8UI
    UInt16RG = LibGL::InternalFormat::RG16UI
    UInt32RG = LibGL::InternalFormat::RG32UI

    UInt8RGB  = LibGL::InternalFormat::RGB8UI
    UInt16RGB = LibGL::InternalFormat::RGB16UI
    UInt32RGB = LibGL::InternalFormat::RGB32UI

    UInt8RGBA  = LibGL::InternalFormat::RGBA8UI
    UInt16RGBA = LibGL::InternalFormat::RGBA16UI
    UInt32RGBA = LibGL::InternalFormat::RGBA32UI

    Int8R  = LibGL::InternalFormat::R8I
    Int16R = LibGL::InternalFormat::R16I
    Int32R = LibGL::InternalFormat::R32I

    Int8RG  = LibGL::InternalFormat::RG8I
    Int16RG = LibGL::InternalFormat::RG16I
    Int32RG = LibGL::InternalFormat::RG32I

    Int8RGB  = LibGL::InternalFormat::RGB8I
    Int16RGB = LibGL::InternalFormat::RGB16I
    Int32RGB = LibGL::InternalFormat::RGB32I

    Int8RGBA  = LibGL::InternalFormat::RGBA8I
    Int16RGBA = LibGL::InternalFormat::RGBA16I
    Int32RGBA = LibGL::InternalFormat::RGBA32I

    Float16R = LibGL::InternalFormat::R16F
    Float32R = LibGL::InternalFormat::R32F

    Float16RG = LibGL::InternalFormat::RG16F
    Float32RG = LibGL::InternalFormat::RG32F

    Float16RGB = LibGL::InternalFormat::RGB16F
    Float32RGB = LibGL::InternalFormat::RGB32F

    Float16RGBA = LibGL::InternalFormat::RGBA16F
    Float32RGBA = LibGL::InternalFormat::RGBA32F

    R   = UIntNormR
    R8  = UInt8NormR
    R16 = UInt16NormR

    RG   = UIntNormRG
    RG8  = UInt8NormRG
    RG16 = UInt16NormRG

    RGB   = UIntNormRGB
    RGB4  = UInt4NormRGB
    RGB5  = UInt5NormRGB
    RGB8  = UInt8NormRGB
    RGB10 = UInt10NormRGB
    RGB12 = UInt12NormRGB
    RGB16 = UInt16NormRGB

    RGBA   = UIntNormRGBA
    RGBA2  = UInt2NormRGBA
    RGBA4  = UInt4NormRGBA
    RGBA8  = UInt8NormRGBA
    RGBA12 = UInt12NormRGBA
    RGBA16 = UInt16NormRGBA

    # Creates a standard image format from its parts.
    #
    # The *components* should be 1, 2, 3, or 4.
    # These correspond to the color components - red, green, blue, and alpha.
    # A value of 1 means only red is used.
    # 2 - red and green; 3 - red, green, and blue; and 4 - all.
    # The symbols `:r`, `:rg`, `:rgb`, and `:rgba` can be used instead.
    #
    # The *depth* indicates the number of bits per component.
    # This can be a variety of things, so check the OpenGL documentation.
    # See: https://www.khronos.org/opengl/wiki/Image_Format#Color_formats
    # `nil` can be used for *depth* to let OpenGL pick.
    # This is only allowed when *type* is `ImageFormatType::UIntNorm`.
    #
    # The *type* specifies how the data is stored and processed.
    # See `ImageFormatType` for details.
    #
    # `ArgumentError` is raised if an unsupported configuration is provided.
    def self.new(*, components = 4, depth = 8, type : ImageFormatType = :u_int_norm) # ameba:disable Metrics/CyclomaticComplexity
      case type
      in .u_int_norm?
        case components
        when 1, :r
          case depth
          when 8   then return ImageFormat::UInt8NormR
          when 16  then return ImageFormat::UInt16NormR
          when nil then return ImageFormat::UIntNormR
          end
        when 2, :rg
          case depth
          when 8   then return ImageFormat::UInt8NormRG
          when 16  then return ImageFormat::UInt16NormRG
          when nil then return ImageFormat::UIntNormRG
          end
        when 3, :rgb
          case depth
          when 4   then return ImageFormat::UInt4NormRGB
          when 5   then return ImageFormat::UInt5NormRGB
          when 8   then return ImageFormat::UInt8NormRGB
          when 10  then return ImageFormat::UInt10NormRGB
          when 12  then return ImageFormat::UInt12NormRGB
          when 16  then return ImageFormat::UInt16NormRGB
          when nil then return ImageFormat::UIntNormRGB
          end
        when 4, :rgba
          case depth
          when 2   then return ImageFormat::UInt2NormRGBA
          when 4   then return ImageFormat::UInt4NormRGBA
          when 8   then return ImageFormat::UInt8NormRGBA
          when 12  then return ImageFormat::UInt12NormRGBA
          when 16  then return ImageFormat::UInt16NormRGBA
          when nil then return ImageFormat::UIntNormRGBA
          end
        end
      in .int_norm?
        case components
        when 1, :r
          case depth
          when  8 then return ImageFormat::Int8NormR
          when 16 then return ImageFormat::Int16NormR
          end
        when 2, :rg
          case depth
          when  8 then return ImageFormat::Int8NormRG
          when 16 then return ImageFormat::Int16NormRG
          end
        when 3, :rgb
          case depth
          when  8 then return ImageFormat::Int8NormRGB
          when 16 then return ImageFormat::Int16NormRGB
          end
        when 4, :rgba
          case depth
          when  8 then return ImageFormat::Int8NormRGBA
          when 16 then return ImageFormat::Int16NormRGBA
          end
        end
      in .u_int?
        case components
        when 1, :r
          case depth
          when  8 then return ImageFormat::UInt8R
          when 16 then return ImageFormat::UInt16R
          when 32 then return ImageFormat::UInt32R
          end
        when 2, :rg
          case depth
          when  8 then return ImageFormat::UInt8RG
          when 16 then return ImageFormat::UInt16RG
          when 32 then return ImageFormat::UInt32RG
          end
        when 3, :rgb
          case depth
          when  8 then return ImageFormat::UInt8RGB
          when 16 then return ImageFormat::UInt16RGB
          when 32 then return ImageFormat::UInt32RGB
          end
        when 4, :rgba
          case depth
          when  8 then return ImageFormat::UInt8RGBA
          when 16 then return ImageFormat::UInt16RGBA
          when 32 then return ImageFormat::UInt32RGBA
          end
        end
      in .int?
        case components
        when 1, :r
          case depth
          when  8 then return ImageFormat::Int8R
          when 16 then return ImageFormat::Int16R
          when 32 then return ImageFormat::Int32R
          end
        when 2, :rg
          case depth
          when  8 then return ImageFormat::Int8RG
          when 16 then return ImageFormat::Int16RG
          when 32 then return ImageFormat::Int32RG
          end
        when 3, :rgb
          case depth
          when  8 then return ImageFormat::Int8RGB
          when 16 then return ImageFormat::Int16RGB
          when 32 then return ImageFormat::Int32RGB
          end
        when 4, :rgba
          case depth
          when  8 then return ImageFormat::Int8RGBA
          when 16 then return ImageFormat::Int16RGBA
          when 32 then return ImageFormat::Int32RGBA
          end
        end
      in .float?
        case components
        when 1, :r
          case depth
          when 16 then return ImageFormat::Float16R
          when 32 then return ImageFormat::Float32R
          end
        when 2, :rg
          case depth
          when 16 then return ImageFormat::Float16RG
          when 32 then return ImageFormat::Float32RG
          end
        when 3, :rgb
          case depth
          when 16 then return ImageFormat::Float16RGB
          when 32 then return ImageFormat::Float32RGB
          end
        when 4, :rgba
          case depth
          when 16 then return ImageFormat::Float16RGBA
          when 32 then return ImageFormat::Float32RGBA
          end
        end
      end

      raise ArgumentError.new("Invalid image format description")
    end

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::InternalFormat.new(value)
    end
  end
end
