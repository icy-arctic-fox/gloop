require "../../spec_helper"

Spectator.describe Gloop::Buffer::Map do
  let(data) { Bytes.new(8, &.to_u8) }
  let(range) { 1..6 }
  let(subdata) { data[range] }
  let(buffer) { Gloop::Buffer.create(context).tap(&.initialize_data(data)) }
  let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }
  subject { buffer.mapping }

  around_each do |example|
    buffer.map(access_mask, range) do |bytes| # ameba:disable Lint/UnusedArgument
      @bytes = bytes
      example.run
    end
  end

  private getter bytes : Bytes = Bytes.empty

  describe "#size" do
    subject { super.size }

    it "is the size of the mapped data" do
      is_expected.to eq(subdata.bytesize)
    end
  end

  describe "#offset" do
    subject { super.offset }

    it "is the start of the mapped data" do
      is_expected.to eq(range.begin)
    end
  end

  describe "#access" do
    subject { super.access }

    it "is the same policy used during the mapping" do
      is_expected.to eq(Gloop::Buffer::Access::ReadWrite)
    end
  end

  describe "#access_mask" do
    subject { super.access_mask }

    it "is the same mask used during the mapping" do
      is_expected.to eq(access_mask)
    end
  end

  describe "#to_slice" do
    subject { super.to_slice }

    it "equals the yielded slice" do
      is_expected.to eq(bytes)
    end
  end

  describe "#to_unsafe" do
    subject { super.to_unsafe }

    def yielded_address
      bytes.to_unsafe.address
    end

    it "returns a pointer to the mapped data" do
      expect(&.address).to eq(yielded_address)
    end
  end
end
