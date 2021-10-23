require "../spec_helper"

Spectator.describe Gloop::RenderCommands do
  subject { context }

  describe "#clear_color=" do
    let(clear_color) { context.clear_color }

    context "with a Color instance" do
      let(color) { Gloop::Color.new(0.12, 0.34, 0.56, 0.78) }

      it "sets the clear color" do
        context.clear_color = color
        aggregate_failures "components" do
          expect(clear_color.red).to be_within(0.00001).of(0.12)
          expect(clear_color.green).to be_within(0.00001).of(0.34)
          expect(clear_color.blue).to be_within(0.00001).of(0.56)
          expect(clear_color.alpha).to be_within(0.00001).of(0.78)
        end
      end
    end

    context "with a tuple" do
      let(color) { {0.12, 0.34, 0.56, 0.78} }

      it "sets the clear color" do
        context.clear_color = color
        aggregate_failures "components" do
          expect(clear_color.red).to be_within(0.00001).of(0.12)
          expect(clear_color.green).to be_within(0.00001).of(0.34)
          expect(clear_color.blue).to be_within(0.00001).of(0.56)
          expect(clear_color.alpha).to be_within(0.00001).of(0.78)
        end
      end
    end
  end

  describe "#clear_depth=" do
    context "with a Float32" do
      it "sets the clear depth" do
        context.clear_depth = 0.42_f32
        expect(&.clear_depth).to be_within(0.00001).of(0.42)
      end
    end

    context "with a Float64" do
      it "sets the clear depth" do
        context.clear_depth = 0.42
        expect(&.clear_depth).to be_within(0.00001).of(0.42)
      end
    end
  end

  describe "#clear_stencil=" do
    it "sets the clear stencil" do
      context.clear_stencil = 42
      expect(&.clear_stencil).to eq(42)
    end
  end
end
