require "../spec_helper"

Spectator.describe Gloop::ImageFormat do
  describe ".new" do
    UIntNorm = Gloop::ImageFormatType::UIntNorm
    IntNorm  = Gloop::ImageFormatType::IntNorm
    UInt     = Gloop::ImageFormatType::UInt
    Int      = Gloop::ImageFormatType::Int
    Float    = Gloop::ImageFormatType::Float

    def format(components, depth, type)
      described_class.new(components: components, depth: depth, type: type).to_unsafe
    end

    it "creates the correct format" do
      aggregate_failures "formats" do
        expect(format(1, 8, UIntNorm)).to eq(LibGL::InternalFormat::R8)
        expect(format(1, 16, UIntNorm)).to eq(LibGL::InternalFormat::R16)

        expect(format(2, 8, UIntNorm)).to eq(LibGL::InternalFormat::RG8)
        expect(format(2, 16, UIntNorm)).to eq(LibGL::InternalFormat::RG16)

        expect(format(3, 4, UIntNorm)).to eq(LibGL::InternalFormat::RGB4)
        expect(format(3, 5, UIntNorm)).to eq(LibGL::InternalFormat::RGB5)
        expect(format(3, 8, UIntNorm)).to eq(LibGL::InternalFormat::RGB8)
        expect(format(3, 10, UIntNorm)).to eq(LibGL::InternalFormat::RGB10)
        expect(format(3, 12, UIntNorm)).to eq(LibGL::InternalFormat::RGB12)
        expect(format(3, 16, UIntNorm)).to eq(LibGL::InternalFormat::RGB16)

        expect(format(4, 2, UIntNorm)).to eq(LibGL::InternalFormat::RGBA2)
        expect(format(4, 4, UIntNorm)).to eq(LibGL::InternalFormat::RGBA4)
        expect(format(4, 8, UIntNorm)).to eq(LibGL::InternalFormat::RGBA8)
        expect(format(4, 12, UIntNorm)).to eq(LibGL::InternalFormat::RGBA12)
        expect(format(4, 16, UIntNorm)).to eq(LibGL::InternalFormat::RGBA16)

        expect(format(1, 8, IntNorm)).to eq(LibGL::InternalFormat::R8SNorm)
        expect(format(1, 16, IntNorm)).to eq(LibGL::InternalFormat::R16SNorm)

        expect(format(2, 8, IntNorm)).to eq(LibGL::InternalFormat::RG8SNorm)
        expect(format(2, 16, IntNorm)).to eq(LibGL::InternalFormat::RG16SNorm)

        expect(format(3, 8, IntNorm)).to eq(LibGL::InternalFormat::RGB8SNorm)
        expect(format(3, 16, IntNorm)).to eq(LibGL::InternalFormat::RGB16SNorm)

        expect(format(4, 8, IntNorm)).to eq(LibGL::InternalFormat::RGBA8SNorm)
        expect(format(4, 16, IntNorm)).to eq(LibGL::InternalFormat::RGBA16SNorm)

        expect(format(1, 8, UInt)).to eq(LibGL::InternalFormat::R8UI)
        expect(format(1, 16, UInt)).to eq(LibGL::InternalFormat::R16UI)
        expect(format(1, 32, UInt)).to eq(LibGL::InternalFormat::R32UI)

        expect(format(2, 8, UInt)).to eq(LibGL::InternalFormat::RG8UI)
        expect(format(2, 16, UInt)).to eq(LibGL::InternalFormat::RG16UI)
        expect(format(2, 32, UInt)).to eq(LibGL::InternalFormat::RG32UI)

        expect(format(3, 8, UInt)).to eq(LibGL::InternalFormat::RGB8UI)
        expect(format(3, 16, UInt)).to eq(LibGL::InternalFormat::RGB16UI)
        expect(format(3, 32, UInt)).to eq(LibGL::InternalFormat::RGB32UI)

        expect(format(4, 8, UInt)).to eq(LibGL::InternalFormat::RGBA8UI)
        expect(format(4, 16, UInt)).to eq(LibGL::InternalFormat::RGBA16UI)
        expect(format(4, 32, UInt)).to eq(LibGL::InternalFormat::RGBA32UI)

        expect(format(1, 8, Int)).to eq(LibGL::InternalFormat::R8I)
        expect(format(1, 16, Int)).to eq(LibGL::InternalFormat::R16I)
        expect(format(1, 32, Int)).to eq(LibGL::InternalFormat::R32I)

        expect(format(2, 8, Int)).to eq(LibGL::InternalFormat::RG8I)
        expect(format(2, 16, Int)).to eq(LibGL::InternalFormat::RG16I)
        expect(format(2, 32, Int)).to eq(LibGL::InternalFormat::RG32I)

        expect(format(3, 8, Int)).to eq(LibGL::InternalFormat::RGB8I)
        expect(format(3, 16, Int)).to eq(LibGL::InternalFormat::RGB16I)
        expect(format(3, 32, Int)).to eq(LibGL::InternalFormat::RGB32I)

        expect(format(4, 8, Int)).to eq(LibGL::InternalFormat::RGBA8I)
        expect(format(4, 16, Int)).to eq(LibGL::InternalFormat::RGBA16I)
        expect(format(4, 32, Int)).to eq(LibGL::InternalFormat::RGBA32I)

        expect(format(1, 16, Float)).to eq(LibGL::InternalFormat::R16F)
        expect(format(1, 32, Float)).to eq(LibGL::InternalFormat::R32F)

        expect(format(2, 16, Float)).to eq(LibGL::InternalFormat::RG16F)
        expect(format(2, 32, Float)).to eq(LibGL::InternalFormat::RG32F)

        expect(format(3, 16, Float)).to eq(LibGL::InternalFormat::RGB16F)
        expect(format(3, 32, Float)).to eq(LibGL::InternalFormat::RGB32F)

        expect(format(4, 16, Float)).to eq(LibGL::InternalFormat::RGBA16F)
        expect(format(4, 32, Float)).to eq(LibGL::InternalFormat::RGBA32F)
      end
    end

    it "supports nil for depth" do
      aggregate_failures "formats" do
        expect(format(1, nil, UIntNorm)).to eq(LibGL::InternalFormat::Red)
        expect(format(2, nil, UIntNorm)).to eq(LibGL::InternalFormat::RG)
        expect(format(3, nil, UIntNorm)).to eq(LibGL::InternalFormat::RGB)
        expect(format(4, nil, UIntNorm)).to eq(LibGL::InternalFormat::RGBA)
      end
    end

    it "supports RGBA symbols" do
      aggregate_failures "formats" do
        expect(format(:r, 8, UIntNorm)).to eq(LibGL::InternalFormat::R8)
        expect(format(:r, 16, UIntNorm)).to eq(LibGL::InternalFormat::R16)

        expect(format(:rg, 8, UIntNorm)).to eq(LibGL::InternalFormat::RG8)
        expect(format(:rg, 16, UIntNorm)).to eq(LibGL::InternalFormat::RG16)

        expect(format(:rgb, 4, UIntNorm)).to eq(LibGL::InternalFormat::RGB4)
        expect(format(:rgb, 5, UIntNorm)).to eq(LibGL::InternalFormat::RGB5)
        expect(format(:rgb, 8, UIntNorm)).to eq(LibGL::InternalFormat::RGB8)
        expect(format(:rgb, 10, UIntNorm)).to eq(LibGL::InternalFormat::RGB10)
        expect(format(:rgb, 12, UIntNorm)).to eq(LibGL::InternalFormat::RGB12)
        expect(format(:rgb, 16, UIntNorm)).to eq(LibGL::InternalFormat::RGB16)

        expect(format(:rgba, 2, UIntNorm)).to eq(LibGL::InternalFormat::RGBA2)
        expect(format(:rgba, 4, UIntNorm)).to eq(LibGL::InternalFormat::RGBA4)
        expect(format(:rgba, 8, UIntNorm)).to eq(LibGL::InternalFormat::RGBA8)
        expect(format(:rgba, 12, UIntNorm)).to eq(LibGL::InternalFormat::RGBA12)
        expect(format(:rgba, 16, UIntNorm)).to eq(LibGL::InternalFormat::RGBA16)

        expect(format(:r, 8, IntNorm)).to eq(LibGL::InternalFormat::R8SNorm)
        expect(format(:r, 16, IntNorm)).to eq(LibGL::InternalFormat::R16SNorm)

        expect(format(:rg, 8, IntNorm)).to eq(LibGL::InternalFormat::RG8SNorm)
        expect(format(:rg, 16, IntNorm)).to eq(LibGL::InternalFormat::RG16SNorm)

        expect(format(:rgb, 8, IntNorm)).to eq(LibGL::InternalFormat::RGB8SNorm)
        expect(format(:rgb, 16, IntNorm)).to eq(LibGL::InternalFormat::RGB16SNorm)

        expect(format(:rgba, 8, IntNorm)).to eq(LibGL::InternalFormat::RGBA8SNorm)
        expect(format(:rgba, 16, IntNorm)).to eq(LibGL::InternalFormat::RGBA16SNorm)

        expect(format(:r, 8, UInt)).to eq(LibGL::InternalFormat::R8UI)
        expect(format(:r, 16, UInt)).to eq(LibGL::InternalFormat::R16UI)
        expect(format(:r, 32, UInt)).to eq(LibGL::InternalFormat::R32UI)

        expect(format(:rg, 8, UInt)).to eq(LibGL::InternalFormat::RG8UI)
        expect(format(:rg, 16, UInt)).to eq(LibGL::InternalFormat::RG16UI)
        expect(format(:rg, 32, UInt)).to eq(LibGL::InternalFormat::RG32UI)

        expect(format(:rgb, 8, UInt)).to eq(LibGL::InternalFormat::RGB8UI)
        expect(format(:rgb, 16, UInt)).to eq(LibGL::InternalFormat::RGB16UI)
        expect(format(:rgb, 32, UInt)).to eq(LibGL::InternalFormat::RGB32UI)

        expect(format(:rgba, 8, UInt)).to eq(LibGL::InternalFormat::RGBA8UI)
        expect(format(:rgba, 16, UInt)).to eq(LibGL::InternalFormat::RGBA16UI)
        expect(format(:rgba, 32, UInt)).to eq(LibGL::InternalFormat::RGBA32UI)

        expect(format(:r, 8, Int)).to eq(LibGL::InternalFormat::R8I)
        expect(format(:r, 16, Int)).to eq(LibGL::InternalFormat::R16I)
        expect(format(:r, 32, Int)).to eq(LibGL::InternalFormat::R32I)

        expect(format(:rg, 8, Int)).to eq(LibGL::InternalFormat::RG8I)
        expect(format(:rg, 16, Int)).to eq(LibGL::InternalFormat::RG16I)
        expect(format(:rg, 32, Int)).to eq(LibGL::InternalFormat::RG32I)

        expect(format(:rgb, 8, Int)).to eq(LibGL::InternalFormat::RGB8I)
        expect(format(:rgb, 16, Int)).to eq(LibGL::InternalFormat::RGB16I)
        expect(format(:rgb, 32, Int)).to eq(LibGL::InternalFormat::RGB32I)
        expect(format(:rgba, 8, Int)).to eq(LibGL::InternalFormat::RGBA8I)
        expect(format(:rgba, 16, Int)).to eq(LibGL::InternalFormat::RGBA16I)
        expect(format(:rgba, 32, Int)).to eq(LibGL::InternalFormat::RGBA32I)

        expect(format(:r, 16, Float)).to eq(LibGL::InternalFormat::R16F)
        expect(format(:r, 32, Float)).to eq(LibGL::InternalFormat::R32F)

        expect(format(:rg, 16, Float)).to eq(LibGL::InternalFormat::RG16F)
        expect(format(:rg, 32, Float)).to eq(LibGL::InternalFormat::RG32F)

        expect(format(:rgb, 16, Float)).to eq(LibGL::InternalFormat::RGB16F)
        expect(format(:rgb, 32, Float)).to eq(LibGL::InternalFormat::RGB32F)

        expect(format(:rgba, 16, Float)).to eq(LibGL::InternalFormat::RGBA16F)
        expect(format(:rgba, 32, Float)).to eq(LibGL::InternalFormat::RGBA32F)
      end
    end
  end
end
