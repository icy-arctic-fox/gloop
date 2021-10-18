require "../../spec_helper"

Spectator.describe Gloop::VertexArray::Current do
  subject(current) { described_class.new(context) }
  let(vao) { Gloop::VertexArray.create(context) }

  describe "#bound?" do
    subject { current.bound? }

    context "when a vertex array is bound" do
      before_each { vao.bind }

      it "is true" do
        is_expected.to be_true
      end
    end

    context "when a vertex array isn't bound" do
      before_each { current.unbind }

      it "is false" do
        is_expected.to be_false
      end
    end
  end

  describe "#unbind" do
    it "unbinds a vertex array" do
      vao.bind
      expect(&.unbind).to change(&.bound?).from(true).to(false)
    end
  end

  describe "#attributes" do
    subject { current.attributes }

    it "is a collection of attributes" do
      is_expected.to be_an(Enumerable(Gloop::Attribute))
    end
  end
end
