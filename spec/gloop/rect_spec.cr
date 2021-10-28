require "../spec_helper"

Spectator.describe Gloop::Rect do
  it "sets the attributes" do
    rect = described_class.new(1, 2, 3, 4)
    expect(rect).to have_attributes(
      x: 1,
      y: 2,
      width: 3,
      height: 4
    )
  end
end
