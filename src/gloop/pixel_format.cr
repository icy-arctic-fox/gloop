module Gloop
  # Describes the structure (components) of a pixel.
  enum PixelFormat : UInt32
    UInt16       = LibGL::PixelFormat::UnsignedShort
    UInt32       = LibGL::PixelFormat::UnsignedInt
    Stencil      = LibGL::PixelFormat::StencilIndex
    Depth        = LibGL::PixelFormat::DepthComponent
    Red          = LibGL::PixelFormat::Red
    Green        = LibGL::PixelFormat::Green
    Blue         = LibGL::PixelFormat::Blue
    Alpha        = LibGL::PixelFormat::Alpha
    RG           = LibGL::PixelFormat::RG
    RGB          = LibGL::PixelFormat::RGB
    RGBA         = LibGL::PixelFormat::RGBA
    BGR          = LibGL::PixelFormat::BGR
    BGRA         = LibGL::PixelFormat::BGRA
    IntRed       = LibGL::PixelFormat::RedInteger
    IntGreen     = LibGL::PixelFormat::GreenInteger
    IntBlue      = LibGL::PixelFormat::BlueInteger
    IntRGB       = LibGL::PixelFormat::RGBInteger
    IntRGBA      = LibGL::PixelFormat::RGBAInteger
    IntBGR       = LibGL::PixelFormat::BGRInteger
    IntBGRA      = LibGL::PixelFormat::BGRAInteger
    IntRG        = LibGL::PixelFormat::RGInteger
    DepthStencil = LibGL::PixelFormat::DepthStencil

    # Creates a pixel format from a symbol.
    #
    # This is intended to be used as a workaround for Crystal's limitations and auto-generated names.
    def self.new(value : Symbol) # ameba:disable Metrics/CyclomaticComplexity
      case value
      when :uint16            then UInt16
      when :uint32            then UInt32
      when :stencil           then Stencil
      when :depth             then Depth
      when :red, :r           then Red
      when :green, :g         then Green
      when :blue, :b          then Blue
      when :alpha, :a         then Alpha
      when :rg                then RG
      when :rgb               then RGB
      when :rgba              then RGBA
      when :bgr               then BGR
      when :bgra              then BGRA
      when :int_red, :int_r   then IntRed
      when :int_green, :int_g then IntGreen
      when :int_blue, :int_b  then IntBlue
      when :int_rgb           then IntRGB
      when :int_rgba          then IntRGBA
      when :int_bgr           then IntBGR
      when :int_bgra          then IntBGRA
      when :int_rg            then IntRG
      when :depth_stencil     then DepthStencil
      else                         raise ArgumentError.new("Invalid pixel format")
      end
    end

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::PixelFormat.new(value)
    end
  end
end
