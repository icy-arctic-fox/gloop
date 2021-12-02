require "../spec_helper"

Spectator.describe Gloop::Textures do
  subject(textures) { described_class.new(context) }

  describe "#texture_1d" do
    subject { textures.texture_1d }

    it "retrieves a binding target for 1D textures" do
      expect(&.target).to eq(Gloop::Texture::Target::Texture1D)
    end
  end

  describe "#texture_2d" do
    subject { textures.texture_2d }

    it "retrieves a binding target for 2D textures" do
      expect(&.target).to eq(Gloop::Texture::Target::Texture2D)
    end
  end

  describe "#texture_3d" do
    subject { textures.texture_3d }

    it "retrieves a binding target for 3D textures" do
      expect(&.target).to eq(Gloop::Texture::Target::Texture3D)
    end
  end

  describe "#texture_1d_array" do
    subject { textures.texture_1d_array }

    it "retrieves a binding target for 1D texture arrays" do
      expect(&.target).to eq(Gloop::Texture::Target::Texture1DArray)
    end
  end

  describe "#texture_2d_array" do
    subject { textures.texture_2d_array }

    it "retrieves a binding target for 2D texture arrays" do
      expect(&.target).to eq(Gloop::Texture::Target::Texture2DArray)
    end
  end

  describe "#rectangle" do
    subject { textures.rectangle }

    it "retrieves a binding target for rectangle textures" do
      expect(&.target).to eq(Gloop::Texture::Target::Rectangle)
    end
  end

  describe "#cube_map" do
    subject { textures.cube_map }

    it "retrieves a binding target for cube map textures" do
      expect(&.target).to eq(Gloop::Texture::Target::CubeMap)
    end
  end

  describe "#cube_map_array" do
    subject { textures.cube_map_array }

    it "retrieves a binding target for cube map texture arrays" do
      expect(&.target).to eq(Gloop::Texture::Target::CubeMapArray)
    end
  end

  describe "#buffer" do
    subject { textures.buffer }

    it "retrieves a binding target for buffer textures" do
      expect(&.target).to eq(Gloop::Texture::Target::Buffer)
    end
  end

  describe "#multi_sample_2d" do
    subject { textures.multi_sample_2d }

    it "retrieves a binding target for 1D textures" do
      expect(&.target).to eq(Gloop::Texture::Target::MultiSample2D)
    end
  end

  describe "#multi_sample_2d_array" do
    subject { textures.multi_sample_2d_array }

    it "retrieves a binding target for multi-sample 2D texture arrays" do
      expect(&.target).to eq(Gloop::Texture::Target::MultiSample2DArray)
    end
  end

  describe "#[]" do
    it "returns a binding target for the specified target" do
      binding = textures[:texture_2d]
      expect(binding.target).to eq(Gloop::Texture::Target::Texture2D)
    end
  end
end

Spectator.describe Gloop::Context do
  describe "#textures" do
    subject { context.textures }

    it "returns a Textures instance" do
      is_expected.to be_a(Gloop::Textures)
    end
  end
end
