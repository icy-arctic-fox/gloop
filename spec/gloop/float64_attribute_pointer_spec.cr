require "../spec_helper"

Spectator.describe Gloop::Float64AttributePointer do
  it "sets the properties" do
    format = described_class.new(2, 64, 256)
    expect(format).to have_attributes(
      size: 2,
      type: Gloop::Float64AttributePointer::Type::Float64,
      stride: 64,
      address: 256
    )
  end
end
