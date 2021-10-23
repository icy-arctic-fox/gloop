require "../spec_helper"

Spectator.describe Gloop::RenderCommands do
  subject { context }
  let(clear_color) { context.clear_color }

  describe "#clear_color=" do
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
end
