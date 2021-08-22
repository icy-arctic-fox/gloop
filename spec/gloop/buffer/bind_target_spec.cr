require "../../spec_helper"

Spectator.describe Gloop::Buffer::BindTarget do
  subject(buffer) { Gloop::Buffer.generate }
  subject(target) { Gloop::Buffers.array }
  before_each { target.bind(buffer) }

  let(data) do
    Bytes.new(8) { |i| i.to_u8 }
  end

  describe "#buffer" do
    subject { target.buffer }

    it "is the currently bound buffer" do
      is_expected.to eq(buffer)
    end

    it "is the null object when no buffer is bound to the target" do
      target.unbind
      is_expected.to be_none
    end
  end

  describe "#bind" do
    before_each { target.unbind }

    it "binds a buffer to the target" do
      expect { target.bind(buffer) }.to change(&.buffer?).from(nil).to(buffer)
    end

    context "with a block" do
      it "rebinds the previous buffer after the block" do
        previous = Gloop::Buffer.generate
        target.bind(previous)
        target.bind(buffer) do
          expect(&.buffer).to eq(buffer)
        end
        expect(&.buffer).to eq(previous)
      end

      it "rebinds the previous buffer on error" do
        previous = Gloop::Buffer.generate
        target.bind(previous)
        expect do
          target.bind(buffer) do
            expect(&.buffer).to eq(buffer)
            raise "oops"
          end
        end.to raise_error("oops")
        expect(&.buffer).to eq(previous)
      end

      it "unbinds the buffer when a previous one wasn't bound" do
        target.unbind
        target.bind(buffer) do
          expect(&.buffer).to eq(buffer)
        end
        expect(&.buffer?).to be_nil
      end
    end
  end

  describe "#unbind" do
    it "removes a previously bound buffer" do
      expect { target.unbind }.to change(&.buffer?).from(buffer).to(nil)
    end
  end

  describe "#usage" do
    subject { target.usage }

    it "retrieves the usage hints" do
      target.data(Bytes.empty, :dynamic_draw)
      is_expected.to eq(Gloop::Buffer::Usage::DynamicDraw)
    end
  end

  describe "#storage_flags" do
    subject { target.storage_flags }
    let(flags) { Gloop::Buffer::Storage.flags(MapRead, MapPersistent, MapCoherent) }
    before_each { target.storage(data, flags) }

    it "retrieves the storage flags" do
      is_expected.to eq(flags)
    end
  end

  describe "#data" do
    subject { target.data }

    it "stores data in the buffer" do
      target.data(data, :static_draw)
      is_expected.to eq(data)
    end

    it "makes the buffer mutable" do
      target.data(data)
      expect(target.immutable?).to be_false
    end
  end

  describe "#allocate_data" do
    it "allocates space for the buffer" do
      target.allocate_data(64)
      expect(target.size).to eq(64)
    end

    it "sets the usage hints" do
      target.allocate_data(64, :dynamic_draw)
      expect(target.usage).to eq(Gloop::Buffer::Usage::DynamicDraw)
    end

    it "makes the buffer mutable" do
      target.allocate_data(64)
      expect(target.immutable?).to be_false
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

    it "makes the buffer mutable" do
      target.data = data
      expect(target.immutable?).to be_false
    end
  end

  describe "#storage" do
    it "stores data in the buffer" do
      target.storage(data, :none)
      expect(target.data).to eq(data)
    end

    it "makes the buffer immutable" do
      target.storage(data, :none)
      expect(target.immutable?).to be_true
    end
  end

  describe "#allocate_storage" do
    it "allocates space for the buffer" do
      target.allocate_storage(64, :none)
      expect(target.size).to eq(64)
    end

    it "sets the storage flags" do
      target.allocate_storage(64, :map_read)
      expect(target.storage_flags).to eq(Gloop::Buffer::Storage::MapRead)
    end

    it "makes the buffer immutable" do
      target.allocate_storage(64, :none)
      expect(target.immutable?).to be_true
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

  describe "#update" do
    let(sub_data) { Bytes[5, 4, 3, 2] }
    before_each { target.data = data }

    it "updates a subset of the buffer" do
      expect { target.update(2, sub_data) }.to change(&.data).to(Bytes[0, 1, 5, 4, 3, 2, 6, 7])
    end
  end

  describe "#[]=" do
    let(sub_data) { Bytes[5, 4, 3, 2] }
    before_each { target.data = data }

    context "with a Range" do
      it "updates a subset of the buffer" do
        expect { target[2..5] = sub_data }.to change(&.data).to(Bytes[0, 1, 5, 4, 3, 2, 6, 7])
      end
    end

    context "with start and count" do
      it "updates a subset of the buffer" do
        expect { target[2, 4] = sub_data }.to change(&.data).to(Bytes[0, 1, 5, 4, 3, 2, 6, 7])
      end
    end
  end
end
