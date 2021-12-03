require "../../spec_helper"

Spectator.describe Gloop::Texture::BindTarget do
  subject(target) { context.textures.texture_2d }
  let(texture) { Gloop::Texture.generate(context) }
  before_each { target.bind(texture) }

  describe "#texture" do
    subject { target.texture }

    it "is the currently bound texture" do
      is_expected.to eq(texture)
    end

    it "is the null object when no texture is bound to the target" do
      target.unbind
      is_expected.to be_none
    end
  end

  describe "#bind" do
    before_each { target.unbind }

    it "binds a texture to the target" do
      expect { target.bind(texture) }.to change(&.texture?).from(nil).to(texture)
    end

    context "with a block" do
      it "rebinds the previous texture after the block" do
        previous = Gloop::Texture.generate(context)
        target.bind(previous)
        target.bind(texture) do
          expect(&.texture).to eq(texture)
        end
        expect(&.texture).to eq(previous)
      end

      it "rebinds the previous texture on error" do
        previous = Gloop::Texture.generate(context)
        target.bind(previous)
        expect do
          target.bind(texture) do
            expect(&.texture).to eq(texture)
            raise "oops"
          end
        end.to raise_error("oops")
        expect(&.texture).to eq(previous)
      end

      it "unbinds the texture when a previous one wasn't bound" do
        target.unbind
        target.bind(texture) do
          expect(&.texture).to eq(texture)
        end
        expect(&.texture?).to be_nil
      end
    end
  end

  describe "#unbind" do
    it "removes a previously bound texture" do
      expect { target.unbind }.to change(&.texture?).from(texture).to(nil)
    end
  end
end
