require "../../spec_helper"

Spectator.describe Gloop::Buffer::BindTarget do
  subject(buffer) { Gloop::Buffer.generate }
  subject(target) { Gloop::Buffers.array }
  before_each { target.bind(buffer) }

  let(data) do
    Bytes.new(8) { |i| i.to_u8 }
  end

  describe "#usage" do
    subject { target.usage }

    it "retrieves the usage hints" do
      target.data(Bytes.empty, :dynamic_draw)
      is_expected.to eq(Gloop::Buffer::Usage::DynamicDraw)
    end
  end

  describe "#data" do
    subject { target.data }

    it "stores data in the buffer" do
      target.data(data, :static_draw)
      is_expected.to eq(data)
    end
  end

  describe "#data=" do
    it "stores data in the buffer" do
      target.data = data
      expect(target.data).to eq(data)
    end

    it "retains the usage hint" do
      target.data(data, :dynamic_draw)
      target.data = data
      expect(target.usage).to eq(Gloop::Buffer::Usage::DynamicDraw)
    end
  end

  describe "#[]" do
    before_each { target.data = data }

    context "with a Range" do
      it "retrieves a subset of data from the buffer" do
        expect(target[1..3]).to eq(Bytes[1, 2, 3])
      end

      it "supports negative offsets" do
        expect(target[-5..-1]).to eq(Bytes[3, 4, 5, 6, 7])
      end

      it "raises on out-of-range values" do
        expect { target[-100..100] }.to raise_error(IndexError)
      end
    end

    context "with start and count" do
      it "retrieves a subset of data from the buffer" do
        expect(target[3, 4]).to eq(Bytes[3, 4, 5, 6])
      end

      it "supports negative offsets" do
        expect(target[-6, 2]).to eq(Bytes[2, 3])
      end

      it "raises on negative counts" do
        expect { target[-1, -2] }.to raise_error(ArgumentError)
      end

      it "raises on out-of-range values" do
        expect { target[-100, 100] }.to raise_error(IndexError)
      end
    end
  end

  describe "#[]?" do
    before_each { target.data = data }

    context "with a Range" do
      it "retrieves a subset of data from the buffer" do
        expect(target[1..3]?).to eq(Bytes[1, 2, 3])
      end

      it "supports negative offsets" do
        expect(target[-5..-1]?).to eq(Bytes[3, 4, 5, 6, 7])
      end

      it "returns nil on out-of-range values" do
        expect(target[-100..100]?).to be_nil
      end
    end

    context "with start and count" do
      it "retrieves a subset of data from the buffer" do
        expect(target[3, 4]?).to eq(Bytes[3, 4, 5, 6])
      end

      it "supports negative offsets" do
        expect(target[-6, 2]?).to eq(Bytes[2, 3])
      end

      it "raises on negative counts" do
        expect { target[-1, -2]? }.to raise_error(ArgumentError)
      end

      it "raises on out-of-range values" do
        expect(target[-100, 100]?).to be_nil
      end
    end
  end
end
