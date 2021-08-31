require "../../spec_helper"

Spectator.describe Gloop::VertexArray::Attributes do
  let(vao) { Gloop::VertexArray.create }
  subject(attributes) { vao.attributes }

  def max_attributes
    LibGL.get_integer_v(LibGL::GetPName::MaxVertexAttribs, out max)
    max
  end

  describe ".max" do
    subject { described_class.max }

    it "is the maximum number of attributes" do
      is_expected.to eq(max_attributes)
    end
  end

  describe "#size" do
    subject { super.size }

    it "is the maximum number of attributes" do
      is_expected.to eq(max_attributes)
    end
  end

  describe "#unsafe_fetch" do
    let(index) { 0 }
    subject(attribute) { attributes.unsafe_fetch(index) }

    it "returns a reference to an attribute" do
      expect(&.index).to eq(index)
    end
  end

  describe "#[]=" do
    context "with Attribute" do
      let(attribute) { Gloop::Float32Attribute.new(3, Float32, 32) }

      it "applies the attribute information" do
        attributes[0] = attribute
        aggregate_failures "attribute parameters" do
          expect(attributes[0].size).to eq(3)
          expect(attributes[0].type).to eq(Gloop::Attribute::Type::Float32)
          expect(attributes[0].offset).to eq(32)
        end
      end
    end

    context "with AttributeIndex" do
      let(attribute) { Gloop::Float32Attribute.new(3, Float32, 32) }
      let(source) { attributes[1] }
      before_each { attributes[1] = attribute }

      it "applies the attribute information" do
        attributes[0] = source
        aggregate_failures "attribute parameters" do
          expect(attributes[0].size).to eq(3)
          expect(attributes[0].type).to eq(Gloop::Attribute::Type::Float32)
          expect(attributes[0].offset).to eq(32)
        end
      end
    end
  end
end