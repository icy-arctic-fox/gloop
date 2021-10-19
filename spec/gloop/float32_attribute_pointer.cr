require "../spec_helper"

Spectator.describe Gloop::Float32AttributePointer do
  it "sets the properties" do
    format = described_class.new(3, :int16, true, 64, 256)
    expect(format).to have_attributes(
      size: 3,
      type: Gloop::Float32AttributePointer::Type::Int16,
      normalized?: true,
      stride: 64,
      address: 256
    )
  end
end
