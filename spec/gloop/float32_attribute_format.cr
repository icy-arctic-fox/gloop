require "../spec_helper"

Spectator.describe Gloop::Float32AttributeFormat do
  it "sets the properties" do
    format = described_class.new(3, :int16, true, 64)
    expect(format).to have_attributes(
      size: 3,
      type: Gloop::Float32AttributeFormat::Type::Int16,
      normalized?: true,
      relative_offset: 64
    )
  end
end
