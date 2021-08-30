require "../../spec_helper"

Spectator.describe Gloop::VertexArray::AttributeIndex do
  let(vao) { Gloop::VertexArray.create }
  subject(attribute) { vao.attributes[0] }

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

  describe "#enabled=" do
    it "enables the attribute" do
      attribute.disable
      expect { attribute.enabled = true }.to change(&.enabled?).from(false).to(true)
    end

    it "disables the attribute" do
      attribute.enable
      expect { attribute.enabled = false }.to change(&.enabled?).from(true).to(false)
    end
  end

  context "parameters" do
    let(definition) { Gloop::Float32Attribute.new(3, Int32, true, 24) }
    before_each { vao.attributes[0] = definition }

    describe "#size" do
      subject { super.size }

      it { is_expected.to eq(3) }
    end

    describe "#type" do
      subject { super.type }

      it { is_expected.to eq(Gloop::Attribute::Type::Int32) }
    end

    describe "#normalized?" do
      subject { super.normalized? }

      it { is_expected.to be_true }
    end

    describe "#offset" do
      subject { super.offset }

      it { is_expected.to eq(24) }
    end

    describe "#stride", pending: "Requires vertex buffer binding" do
      subject { super.stride }

      it { is_expected.to eq(24) }
    end

    describe "#divisor", pending: "Requires attribute divisor setter" do
      subject { super.divisor }

      it { is_expected.to eq(1) }
    end

    describe "#integer?" do
      subject { super.integer? }

      it { is_expected.to be_false }

      context "with an integer format" do
        let(definition) { Gloop::Int32Attribute.new(3, :int16, 24) }

        it { is_expected.to be_true }
      end
    end

    describe "#long?" do
      subject { super.long? }

      it { is_expected.to be_false }

      context "with a double format" do
        let(definition) { Gloop::Float64Attribute.new(3, 24) }

        it { is_expected.to be_true }
      end
    end
  end
end
