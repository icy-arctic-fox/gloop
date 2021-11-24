require "../spec_helper"

Spectator.describe Gloop::Texture do
  subject(texture) { described_class.create(context, :_2d) }

  describe ".create" do
    it "creates a texture" do
      texture = described_class.create(context, :texture_2d)
      expect(texture.exists?).to be_true
    end

    it "creates multiple textures" do
      textures = described_class.create(context, :texture_2d, 3)
      aggregate_failures do
        expect(textures[0].exists?).to be_true
        expect(textures[1].exists?).to be_true
        expect(textures[2].exists?).to be_true
      end
    end
  end

  describe ".generate" do
    pending "creates a textures", pending: "Texture#bind not implemented" do
      textures = described_class.generate(context)
      textures.bind
      expect(vao.exists?).to be_true
    end

    pending "creates multiple textures", pending: "Texture#bind not implemented" do
      textures = described_class.generate(context, 3)
      aggregate_failures do
        3.times do |i|
          textures[i].bind
          expect(textures[i].exists?).to be_true
        end
      end
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
      textures = described_class.create(context, :texture_2d, 3)
      described_class.delete(textures)
      aggregate_failures do
        expect(textures[0].exists?).to be_false
        expect(textures[1].exists?).to be_false
        expect(textures[2].exists?).to be_false
      end
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
      aggregate_failures do
        expect(textures[0].exists?).to be_true
        expect(textures[1].exists?).to be_true
        expect(textures[2].exists?).to be_true
      end
    ensure
      textures.delete if textures
    end
  end

  describe "#generate_texture" do
    pending "creates a texture", pending: "Texture#bind is not implemented" do
      texture = context.generate_texture
      texture.bind
      expect(texture.exists?).to be_true
    ensure
      texture.try(&.delete)
    end
  end

  describe "#generate_textures" do
    pending "creates multiple textures", pending: "Texture#bind is not implemented" do
      textures = context.generate_textures(3)
      aggregate_failures do
        3.times do |i|
          textures[i].bind
          expect(textures[i].exists?).to be_true
        end
      end
    ensure
      textures.delete if textures
    end
  end
end

Spectator.describe Gloop::TextureList do
  subject(list) { Gloop::Texture.create(context, :texture_2d, 3) }

  it "holds textures" do
    is_expected.to be_an(Indexable(Gloop::Texture))
    expect(&.size).to eq(3)
    aggregate_failures "textures" do
      expect(list[0]).to be_a(Gloop::Texture)
      expect(list[1]).to be_a(Gloop::Texture)
      expect(list[2]).to be_a(Gloop::Texture)
    end
  end

  describe "#delete" do
    it "deletes all textures" do
      list.delete
      aggregate_failures "textures" do
        list.each do |texture|
          expect(texture.exists?).to be_false
        end
      end
    end
  end
end
