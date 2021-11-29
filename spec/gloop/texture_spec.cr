require "../spec_helper"

Spectator.describe Gloop::Texture do
  subject(texture) { described_class.create(context, :_2d) }

  describe ".create" do
    it "creates a texture" do
      texture = described_class.create(context, :texture_2d)
      expect(texture.exists?).to be_true
    end
  end

  describe ".generate" do
    it "creates a texture" do
      texture = described_class.generate(context)
      texture.bind(:texture_2d)
      expect(texture.exists?).to be_true
    end
  end

  describe ".none" do
    subject { described_class.none(context) }

    it "is a null object" do
      expect(&.none?).to be_true
    end
  end

  describe ".delete" do
    it "deletes textures" do
      textures = Array.new(3) { described_class.create(context, :texture_2d) }
      described_class.delete(textures)
      expect(textures.map(&.exists?)).to all(be_false)
    end
  end

  describe "#delete" do
    it "deletes the texture" do
      expect { texture.delete }.to change(&.exists?).from(true).to(false)
    end
  end

  describe "#depth_stencil_mode=" do
    it "sets the depth-stencil mode" do
      expect { texture.depth_stencil_mode = :stencil }.to change(&.depth_stencil_mode).to(Gloop::Texture::DepthStencilMode::Stencil)
    end
  end

  describe "#base_level=" do
    it "sets the minimum mipmap level" do
      expect { texture.base_level = 1 }.to change(&.base_level).to(1)
    end
  end

  describe "#max_level=" do
    it "sets the maximum mipmap level" do
      expect { texture.max_level = 5 }.to change(&.max_level).to(5)
    end
  end

  describe "#mag_filter=" do
    it "sets the magnification method" do
      texture.mag_filter = :linear
      expect { texture.mag_filter = :nearest }.to change(&.mag_filter).to(Gloop::Texture::MagFilter::Nearest)
    end
  end

  describe "#min_filter=" do
    it "sets the minification method" do
      texture.min_filter = :linear
      expect { texture.min_filter = :nearest }.to change(&.min_filter).to(Gloop::Texture::MinFilter::Nearest)
    end
  end

  describe "#min_lod=" do
    it "sets the minimum level-of-detail" do
      expect { texture.min_lod = -50 }.to change(&.min_lod).to(-50)
    end
  end

  describe "#max_lod=" do
    it "sets the maximum level-of-detail" do
      expect { texture.max_lod = 50 }.to change(&.max_lod).to(50)
    end
  end

  describe "#wrap_s=" do
    it "sets the wrap mode for the s-coordinate" do
      texture.wrap_s = :repeat
      expect { texture.wrap_s = :clamp_to_edge }.to change(&.wrap_s).to(Gloop::Texture::WrapMode::ClampToEdge)
    end
  end

  describe "#wrap_t=" do
    it "sets the wrap mode for the t-coordinate" do
      texture.wrap_t = :repeat
      expect { texture.wrap_t = :clamp_to_edge }.to change(&.wrap_t).to(Gloop::Texture::WrapMode::ClampToEdge)
    end
  end

  describe "#wrap_r=" do
    it "sets the wrap mode for the r-coordinate" do
      texture.wrap_r = :repeat
      expect { texture.wrap_r = :clamp_to_edge }.to change(&.wrap_r).to(Gloop::Texture::WrapMode::ClampToEdge)
    end
  end

  describe "#swizzle_red=" do
    it "sets the swizzle for the red component" do
      expect { texture.swizzle_red = :zero }.to change(&.swizzle_red).to(Gloop::Texture::Swizzle::Zero)
    end
  end

  describe "#swizzle_green=" do
    it "sets the swizzle for the green component" do
      expect { texture.swizzle_green = :zero }.to change(&.swizzle_green).to(Gloop::Texture::Swizzle::Zero)
    end
  end

  describe "#swizzle_blue=" do
    it "sets the swizzle for the blue component" do
      expect { texture.swizzle_blue = :zero }.to change(&.swizzle_blue).to(Gloop::Texture::Swizzle::Zero)
    end
  end

  describe "#swizzle_alpha=" do
    it "sets the swizzle for the alpha component" do
      expect { texture.swizzle_alpha = :zero }.to change(&.swizzle_alpha).to(Gloop::Texture::Swizzle::Zero)
    end
  end

  describe "#swizzle" do
    it "retrieves the swizzle for all components" do
      texture.swizzle_red = :alpha
      texture.swizzle_green = :blue
      texture.swizzle_blue = :green
      texture.swizzle_alpha = :red
      swizzle = {Gloop::Texture::Swizzle::Alpha, Gloop::Texture::Swizzle::Blue, Gloop::Texture::Swizzle::Green, Gloop::Texture::Swizzle::Red}
      expect(&.swizzle).to eq(swizzle)
    end
  end

  describe "#swizzle=" do
    it "sets the swizzle for all components" do
      texture.swizzle = {Gloop::Texture::Swizzle::Alpha, Gloop::Texture::Swizzle::Blue, Gloop::Texture::Swizzle::Green, Gloop::Texture::Swizzle::Red}
      expect(texture).to have_attributes(
        swizzle_red: Gloop::Texture::Swizzle::Alpha,
        swizzle_green: Gloop::Texture::Swizzle::Blue,
        swizzle_blue: Gloop::Texture::Swizzle::Green,
        swizzle_alpha: Gloop::Texture::Swizzle::Red
      )
    end
  end

  context "Labelable" do
    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end

Spectator.describe Gloop::Context do
  subject { context }
  let(texture) { context.create_texture }

  describe "#create_texture" do
    it "creates a texture" do
      texture = context.create_texture(:texture_2d)
      expect(texture.exists?).to be_true
    ensure
      texture.try(&.delete)
    end
  end

  describe "#create_textures" do
    it "creates multiple textures" do
      textures = context.create_textures(:texture_2d, 3)
      expect(textures.map(&.exists?)).to all(be_true)
    ensure
      textures.try(&.delete)
    end
  end

  describe "#generate_texture" do
    it "creates a texture" do
      texture = context.generate_texture
      texture.bind(:texture_2d)
      expect(texture.exists?).to be_true
    ensure
      texture.try(&.delete)
    end
  end

  describe "#generate_textures" do
    it "creates multiple textures" do
      textures = context.generate_textures(3)
      textures.each(&.bind(:texture_2d))
      expect(textures.map(&.exists?)).to all(be_true)
    ensure
      textures.try(&.delete)
    end
  end
end

Spectator.describe Gloop::TextureList do
  subject(list) { described_class.create(context, :texture_2d, 3) }

  describe ".create" do
    it "creates multiple textures" do
      textures = described_class.create(context, :texture_2d, 3)
      expect(textures.map(&.exists?)).to all(be_true)
    ensure
      textures.try(&.delete)
    end
  end

  describe ".generate" do
    it "creates multiple textures" do
      textures = described_class.generate(context, 3)
      textures.each(&.bind(:texture_2d))
      expect(textures.map(&.exists?)).to all(be_true)
    ensure
      textures.try(&.delete)
    end
  end

  describe "#delete" do
    it "deletes all textures" do
      list.delete
      expect(list.map(&.exists?)).to all(be_false)
    end
  end
end
