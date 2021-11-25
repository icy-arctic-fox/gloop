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
