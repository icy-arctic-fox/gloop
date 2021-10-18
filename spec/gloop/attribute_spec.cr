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

  describe "#float32_format" do
    it "sets the format of the attribute" do
      attribute.float32_format(3, :int16, true, 16_u32)
      aggregate_failures "attribute format" do
        expect(&.normalized?).to be_true
        expect(&.integer?).to be_false
        expect(&.float64?).to be_false
        expect(&.size).to eq(3)
        expect(&.stride).to eq(0)
        expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Int16)
        expect(&.offset).to eq(16)
      end
    end
  end

  describe "#int_format" do
    it "sets the format of the attribute" do
      attribute.int_format(4, :int8, 16_u32)
      aggregate_failures "attribute format" do
        expect(&.normalized?).to be_false
        expect(&.integer?).to be_true
        expect(&.float64?).to be_false
        expect(&.size).to eq(4)
        expect(&.stride).to eq(0)
        expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Int8)
        expect(&.offset).to eq(16)
      end
    end
  end

  describe "#float64_format" do
    it "sets the format of the attribute" do
      attribute.float64_format(2, 32_u32)
      aggregate_failures "attribute format" do
        expect(&.normalized?).to be_false
        expect(&.integer?).to be_false
        expect(&.float64?).to be_true
        expect(&.size).to eq(2)
        expect(&.stride).to eq(0)
        expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Float64)
        expect(&.offset).to eq(32)
      end
    end
  end

  describe "#format=" do
    context "with Float32AttributeFormat" do
      let(format) { Gloop::Float32AttributeFormat.new(3, :int16, true, 16) }

      it "sets the format of the attribute" do
        attribute.format = format
        aggregate_failures "attribute format" do
          expect(&.normalized?).to be_true
          expect(&.integer?).to be_false
          expect(&.float64?).to be_false
          expect(&.size).to eq(3)
          expect(&.stride).to eq(0)
          expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Int16)
          expect(&.offset).to eq(16)
        end
      end
    end

    context "with IntAttributeFormat" do
      let(format) { Gloop::IntAttributeFormat.new(4, :int8, 16) }

      it "sets the format of the attribute" do
        attribute.format = format
        aggregate_failures "attribute format" do
          expect(&.normalized?).to be_false
          expect(&.integer?).to be_true
          expect(&.float64?).to be_false
          expect(&.size).to eq(4)
          expect(&.stride).to eq(0)
          expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Int8)
          expect(&.offset).to eq(16)
        end
      end
    end

    context "with Float64AttributeFormat" do
      let(format) { Gloop::Float64AttributeFormat.new(2, 32) }

      it "sets the format of the attribute" do
        attribute.format = format
        aggregate_failures "attribute format" do
          expect(&.normalized?).to be_false
          expect(&.integer?).to be_false
          expect(&.float64?).to be_true
          expect(&.size).to eq(2)
          expect(&.stride).to eq(0)
          expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Float64)
          expect(&.offset).to eq(32)
        end
      end
    end
  end
end
