require "../spec_helper"

Spectator.describe Gloop::IntAttributeFormat do
  it "sets the properties" do
    format = described_class.new(2, :int32, 64)
    expect(format).to have_attributes(
      size: 2,
      type: Gloop::IntAttributeFormat::Type::Int32,
      relative_offset: 64
    )
  end
end
