require "../spec_helper"

Spectator.describe Gloop::Color do
  subject { described_class.new(0.1962, 0.3493, 0.4545, 0.75) }

  it "sets the components" do
    aggregate_failures "components" do
      expect(&.red).to be_within(0.00001).of(0.1962)
      expect(&.green).to be_within(0.00001).of(0.3493)
      expect(&.blue).to be_within(0.00001).of(0.4545)
      expect(&.alpha).to be_within(0.00001).of(0.75)
    end
  end
end
