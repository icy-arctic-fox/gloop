require "../spec_helper"

Spectator.describe Gloop::IntAttributePointer do
  it "sets the properties" do
    format = described_class.new(2, :int32, 64, 256)
    expect(format).to have_attributes(
      size: 2,
      type: Gloop::IntAttributePointer::Type::Int32,
      stride: 64,
      address: 256
    )
  end
end
