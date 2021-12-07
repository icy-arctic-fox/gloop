module Gloop
  # Describes how components of a pixel are stored in memory.
  enum PixelType : UInt32
    # Each component is stored as a signed 8-bit integer.
    Int8 = LibGL::PixelType::Byte

    # Each component is stored as an unsigned 8-bit integer.
    UInt8 = LibGL::PixelType::UnsignedByte

    # Each component is stored as a signed 16-bit integer.
    Int16 = LibGL::PixelType::Short

    # Each component is stored as an unsigned 16-bit integer.
    UInt16 = LibGL::PixelType::UnsignedShort

    # Each component is stored as a signed 32-bit integer.
    Int32 = LibGL::PixelType::Int

    # Each component is stored as an unsigned 32-bit integer.
    UInt32 = LibGL::PixelType::UnsignedInt

    # Each component is stored as a 32-bit floating-point number.
    Float32 = LibGL::PixelType::Float

    # Three components stored in 8 bits.
    #
    # 3 bits for red, 3 bits for green, and 2 bits for blue.
    UInt8R3G3B2 = LibGL::PixelType::UnsignedByte332

    # Four components stored in 16 bits.
    #
    # 4 bits for each component.
    UInt16R4G4B4A4 = LibGL::PixelType::UnsignedShort4444

    # Four components stored in 16 bits.
    #
    # 4 bits each for red, green, and blue and 1 bit for alpha.
    UInt16R5G5B5A1 = LibGL::PixelType::UnsignedShort5551

    # Four components stored in 32 bits.
    #
    # 8 bits for each component.
    UInt32R8G8B8A8 = LibGL::PixelType::UnsignedInt8888

    # Four components stored in 32 bits.
    #
    # 8 bits each for red, green, and blue and 2 bits for alpha.
    UInt32R10G10B10A2 = LibGL::PixelType::UnsignedInt1010102

    # Creates a pixel type from a symbol.
    #
    # This is intended to be used as a workaround for Crystal's limitations and auto-generated names.
    def self.new(value : Symbol) # ameba:disable Metrics/CyclomaticComplexity
      case value
      when :int8                                                     then Int8
      when :uint8                                                    then UInt8
      when :int16                                                    then Int16
      when :uint16                                                   then UInt16
      when :int32                                                    then Int32
      when :uint32                                                   then UInt32
      when :float32                                                  then Float32
      when :uint8_r3g3b2, :uint8_332, :uint_332                      then UInt8R3G3B2
      when :uint16_r4g4b4a4, :uint16_4444, :uint_4444                then UInt16R4G4B4A4
      when :uint16_r5g5b5a1, :uint16_5551, :uint_5551                then UInt16R5G5B5A1
      when :uint32_r8g8b8a8, :uint32_8888, :uint_8888                then UInt32R8G8B8A8
      when :uint32_r10g10b10a2, :uint32_10_10_10_2, :uint_10_10_10_2 then UInt32R10G10B10A2
      else                                                                raise ArgumentError.new("Invalid pixel type")
      end
    end

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::PixelType.new(value)
    end
  end
end
