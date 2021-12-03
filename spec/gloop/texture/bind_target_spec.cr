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

  describe "#depth_stencil_mode=" do
    it "sets the depth-stencil mode" do
      expect { target.depth_stencil_mode = :stencil }.to change(&.depth_stencil_mode).to(Gloop::Texture::DepthStencilMode::Stencil)
    end
  end

  describe "#base_level=" do
    it "sets the minimum mipmap level" do
      expect { target.base_level = 1 }.to change(&.base_level).to(1)
    end
  end

  describe "#max_level=" do
    it "sets the maximum mipmap level" do
      expect { target.max_level = 5 }.to change(&.max_level).to(5)
    end
  end

  describe "#mag_filter=" do
    it "sets the magnification method" do
      target.mag_filter = :linear
      expect { target.mag_filter = :nearest }.to change(&.mag_filter).to(Gloop::Texture::MagFilter::Nearest)
    end
  end

  describe "#min_filter=" do
    it "sets the minification method" do
      target.min_filter = :linear
      expect { target.min_filter = :nearest }.to change(&.min_filter).to(Gloop::Texture::MinFilter::Nearest)
    end
  end

  describe "#min_lod=" do
    it "sets the minimum level-of-detail" do
      expect { target.min_lod = -50 }.to change(&.min_lod).to(-50)
    end
  end

  describe "#max_lod=" do
    it "sets the maximum level-of-detail" do
      expect { target.max_lod = 50 }.to change(&.max_lod).to(50)
    end
  end

  describe "#lod_bias=" do
    it "sets the level-of-detail bias" do
      expect { target.lod_bias = 50 }.to change(&.lod_bias).to(50)
    end
  end

  describe "#compare_mode=" do
    it "sets the comparison mode" do
      expect { target.compare_mode = :compare_ref_to_texture }.to change(&.compare_mode).to(Gloop::Texture::CompareMode::CompareRefToTexture)
    end
  end

  describe "#compare_function=" do
    it "sets the depth comparison method" do
      expect { target.compare_function = :always }.to change(&.compare_function).to(Gloop::DepthFunction::Always)
    end
  end

  describe "#wrap_s=" do
    it "sets the wrap mode for the s-coordinate" do
      target.wrap_s = :repeat
      expect { target.wrap_s = :clamp_to_edge }.to change(&.wrap_s).to(Gloop::Texture::WrapMode::ClampToEdge)
    end
  end

  describe "#wrap_t=" do
    it "sets the wrap mode for the t-coordinate" do
      target.wrap_t = :repeat
      expect { target.wrap_t = :clamp_to_edge }.to change(&.wrap_t).to(Gloop::Texture::WrapMode::ClampToEdge)
    end
  end

  describe "#wrap_r=" do
    it "sets the wrap mode for the r-coordinate" do
      target.wrap_r = :repeat
      expect { target.wrap_r = :clamp_to_edge }.to change(&.wrap_r).to(Gloop::Texture::WrapMode::ClampToEdge)
    end
  end

  describe "#swizzle_red=" do
    it "sets the swizzle for the red component" do
      expect { target.swizzle_red = :zero }.to change(&.swizzle_red).to(Gloop::Texture::Swizzle::Zero)
    end
  end

  describe "#swizzle_green=" do
    it "sets the swizzle for the green component" do
      expect { target.swizzle_green = :zero }.to change(&.swizzle_green).to(Gloop::Texture::Swizzle::Zero)
    end
  end

  describe "#swizzle_blue=" do
    it "sets the swizzle for the blue component" do
      expect { target.swizzle_blue = :zero }.to change(&.swizzle_blue).to(Gloop::Texture::Swizzle::Zero)
    end
  end

  describe "#swizzle_alpha=" do
    it "sets the swizzle for the alpha component" do
      expect { target.swizzle_alpha = :zero }.to change(&.swizzle_alpha).to(Gloop::Texture::Swizzle::Zero)
    end
  end

  describe "#swizzle" do
    it "retrieves the swizzle for all components" do
      target.swizzle_red = :alpha
      target.swizzle_green = :blue
      target.swizzle_blue = :green
      target.swizzle_alpha = :red
      swizzle = {Gloop::Texture::Swizzle::Alpha, Gloop::Texture::Swizzle::Blue, Gloop::Texture::Swizzle::Green, Gloop::Texture::Swizzle::Red}
      expect(&.swizzle).to eq(swizzle)
    end
  end

  describe "#swizzle=" do
    it "sets the swizzle for all components" do
      target.swizzle = {Gloop::Texture::Swizzle::Alpha, Gloop::Texture::Swizzle::Blue, Gloop::Texture::Swizzle::Green, Gloop::Texture::Swizzle::Red}
      expect(target).to have_attributes(
        swizzle_red: Gloop::Texture::Swizzle::Alpha,
        swizzle_green: Gloop::Texture::Swizzle::Blue,
        swizzle_blue: Gloop::Texture::Swizzle::Green,
        swizzle_alpha: Gloop::Texture::Swizzle::Red
      )
    end
  end

  describe "#border_color=" do
    context "with a color" do
      let(color) { Gloop::Color.new(0.1, 0.3, 0.5, 0.7) }

      it "sets the border color" do
        target.border_color = color
        expect(&.border_color).to eq(color)
      end
    end

    context "with floats" do
      let(color) { {0.2, 0.4, 0.6, 0.8} }

      it "sets the border color" do
        target.border_color = color
        expect(&.border_color(Float32)).to eq(color.map(&.to_f32))
      end
    end

    context "with signed integers" do
      let(color) { {100, 200, 300, 400} }

      it "sets the border color" do
        target.border_color = color
        expect(&.border_color(Int32)).to eq(color)
      end
    end

    context "with unsigned integers" do
      let(color) { {1000_u32, 2000_u32, 3000_u32, 4000_u32} }

      it "sets the border color" do
        target.border_color = color
        expect(&.border_color(UInt32)).to eq(color)
      end
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
