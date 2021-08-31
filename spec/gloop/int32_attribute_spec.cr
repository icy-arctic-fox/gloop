require "../spec_helper"

Spectator.describe Gloop::Int32Attribute do
  subject(attribute) { Gloop::Attributes[0] }

  let(vao) { Gloop::VertexArray.create }
  before_each { vao.bind }
  after_each { Gloop::VertexArray.unbind }

  # Unused definition, should be overridden.
  let!(definition) { described_class.new(0, :uint8, 0) }
  before_each { Gloop::Attributes[0] = definition }

  context "generic" do
    let(definition) { described_class.new(3, :int16, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int16)
        expect(&.offset).to eq(32)
      end
    end
  end

  context "Int8" do
    let(definition) { described_class.new(3, Int8, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int8)
        expect(&.offset).to eq(32)
      end
    end
  end

  context "UInt8" do
    let(definition) { described_class.new(3, UInt8, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt8)
        expect(&.offset).to eq(32)
      end
    end
  end

  context "Int16" do
    let(definition) { described_class.new(3, Int16, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int16)
        expect(&.offset).to eq(32)
      end
    end
  end

  context "UInt16" do
    let(definition) { described_class.new(3, UInt16, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt16)
        expect(&.offset).to eq(32)
      end
    end
  end

  context "Int32" do
    let(definition) { described_class.new(3, Int32, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int32)
        expect(&.offset).to eq(32)
      end
    end
  end

  context "UInt32" do
    let(definition) { described_class.new(3, UInt32, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt32)
        expect(&.offset).to eq(32)
      end
    end
  end
end
