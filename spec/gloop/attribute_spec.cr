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

  describe "#float32_pointer" do
    let(buffer) { Gloop::Buffer.generate(context) }
    before_each { context.buffers.array.bind(buffer) }
    after_each { buffer.delete }

    it "sets the format of the attribute" do
      attribute.float32_pointer(3, :int16, true, 128, 16_u32)
      aggregate_failures "attribute format" do
        expect(&.normalized?).to be_true
        expect(&.integer?).to be_false
        expect(&.float64?).to be_false
        expect(&.size).to eq(3)
        expect(&.stride).to eq(128)
        expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Int16)
        expect(&.address).to eq(16)
      end
    end
  end

  describe "#int_pointer" do
    let(buffer) { Gloop::Buffer.generate(context) }
    before_each { context.buffers.array.bind(buffer) }
    after_each { buffer.delete }

    it "sets the format of the attribute" do
      attribute.int_pointer(4, :int8, 128, 16_u32)
      aggregate_failures "attribute format" do
        expect(&.normalized?).to be_false
        expect(&.integer?).to be_true
        expect(&.float64?).to be_false
        expect(&.size).to eq(4)
        expect(&.stride).to eq(128)
        expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Int8)
        expect(&.address).to eq(16)
      end
    end
  end

  describe "#float64_pointer" do
    let(buffer) { Gloop::Buffer.generate(context) }
    before_each { context.buffers.array.bind(buffer) }
    after_each { buffer.delete }

    it "sets the format of the attribute" do
      attribute.float64_pointer(2, 128, 32_u32)
      aggregate_failures "attribute format" do
        expect(&.normalized?).to be_false
        expect(&.integer?).to be_false
        expect(&.float64?).to be_true
        expect(&.size).to eq(2)
        expect(&.stride).to eq(128)
        expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Float64)
        expect(&.address).to eq(32)
      end
    end
  end

  describe "#pointer=" do
    let(buffer) { Gloop::Buffer.generate(context) }
    before_each { context.buffers.array.bind(buffer) }
    after_each { buffer.delete }

    context "with Float32AttributePointer" do
      let(pointer) { Gloop::Float32AttributePointer.new(3, :int16, true, 128, 16) }

      it "sets the format of the attribute" do
        attribute.pointer = pointer
        aggregate_failures "attribute format" do
          expect(&.normalized?).to be_true
          expect(&.integer?).to be_false
          expect(&.float64?).to be_false
          expect(&.size).to eq(3)
          expect(&.stride).to eq(128)
          expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Int16)
          expect(&.address).to eq(16)
        end
      end
    end

    context "with IntAttributePointer" do
      let(pointer) { Gloop::IntAttributePointer.new(4, :int8, 128, 16) }

      it "sets the format of the attribute" do
        attribute.pointer = pointer
        aggregate_failures "attribute format" do
          expect(&.normalized?).to be_false
          expect(&.integer?).to be_true
          expect(&.float64?).to be_false
          expect(&.size).to eq(4)
          expect(&.stride).to eq(128)
          expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Int8)
          expect(&.address).to eq(16)
        end
      end
    end

    context "with Float64AttributePointer" do
      let(pointer) { Gloop::Float64AttributePointer.new(2, 128, 32) }

      it "sets the format of the attribute" do
        attribute.pointer = pointer
        aggregate_failures "attribute format" do
          expect(&.normalized?).to be_false
          expect(&.integer?).to be_false
          expect(&.float64?).to be_true
          expect(&.size).to eq(2)
          expect(&.stride).to eq(128)
          expect(&.type).to eq(Gloop::Float32AttributeFormat::Type::Float64)
          expect(&.address).to eq(32)
        end
      end
    end
  end

  describe "#format" do
    subject { attribute.format }

    before_each { attribute.int_format(4, :int8, 16_u32) }

    it "retrieves the format of the attribute" do
      is_expected.to be_a(Gloop::IntAttributeFormat)
      is_expected.to have_attributes(
        size: 4,
        type: Gloop::IntAttributeFormat::Type::Int8,
        offset: 16
      )
    end
  end

  describe "#pointer" do
    subject { attribute.pointer }
    let(buffer) { Gloop::Buffer.generate(context) }

    before_each { context.buffers.array.bind(buffer) }
    before_each { attribute.int_pointer(4, :int8, 128, 16) }
    after_each { buffer.delete }

    it "retrieves the format of the attribute" do
      is_expected.to be_a(Gloop::IntAttributePointer)
      is_expected.to have_attributes(
        size: 4,
        type: Gloop::IntAttributePointer::Type::Int8,
        stride: 128,
        address: 16
      )
    end
  end
end
