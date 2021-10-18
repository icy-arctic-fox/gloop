require "../spec_helper"

Spectator.describe Gloop::Attribute do
  subject(attribute) { Gloop::Attribute.new(context, index) }
  let(vao) { Gloop::VertexArray.create(context) }
  let(index) { 2_u32 }

  before_each { vao.bind }

  describe "#index" do
    subject { attribute.index }

    it "is the attribute's index" do
      is_expected.to eq(index)
    end
  end

  describe "#enable" do
    before_each { attribute.disable }

    it "enables the attribute" do
      expect(&.enable).to change(&.enabled?).from(false).to(true)
    end
  end

  describe "#disable" do
    before_each { attribute.enable }

    it "disables the attribute" do
      expect(&.disable).to change(&.enabled?).from(true).to(false)
    end
  end
end
