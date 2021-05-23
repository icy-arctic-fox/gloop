require "../spec_helper"

Spectator.describe Gloop::Extension do
  it "stores the name" do
    extension = described_class.new("Test_Extension")
    expect(extension.name).to eq("Test_Extension")
  end
end
