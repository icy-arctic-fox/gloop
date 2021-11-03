require "../spec_helper"

Spectator.describe Gloop::Float64AttributeFormat do
  it "sets the properties" do
    format = described_class.new(2, 64)
    expect(format).to have_attributes(
      size: 2,
      type: Gloop::Float64AttributeFormat::Type::Float64,
      relative_offset: 64
    )
  end
end
