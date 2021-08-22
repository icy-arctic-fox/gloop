require "../spec_helper"

Spectator.describe Gloop::Buffer do
  subject(buffer) { described_class.create }

  let(data) { Bytes.new(8, &.to_u8) }

  describe ".create" do
    it "creates a buffer" do
      buffer = described_class.create
      expect(buffer.exists?).to be_true
    ensure
      buffer.try(&.delete)
    end

    it "creates multiple buffers" do
      buffers = described_class.create(3)
      aggregate_failures do
        expect(buffers[0].exists?).to be_true
        expect(buffers[1].exists?).to be_true
        expect(buffers[2].exists?).to be_true
      end
    ensure
      described_class.delete(buffers) if buffers
    end
  end

  describe ".generate" do
    it "creates a buffer" do
      buffer = described_class.generate
      buffer.bind(:array)
      expect(buffer.exists?).to be_true
    ensure
      buffer.try(&.delete)
    end

    it "creates multiple buffers" do
      buffers = described_class.generate(3)
      aggregate_failures do
        3.times do |i|
          buffers[i].bind(:array)
          expect(buffers[i].exists?).to be_true
        end
      end
    ensure
      described_class.delete(buffers) if buffers
    end
  end

  describe ".none" do
    subject { described_class.none }

    it "is a null object" do
      expect(&.none?).to be_true
    end
  end

  describe ".mutable" do
    subject(buffer) { described_class.mutable(data, :dynamic_draw) }

    it "populates the data" do
      expect(buffer.data).to eq(data)
    end

    it "sets the usage hints" do
      expect(buffer.usage).to eq(Gloop::Buffer::Usage::DynamicDraw)
    end

    it "creates a mutable buffer" do
      expect(buffer.immutable?).to be_false
    end
  end

  describe ".immutable" do
    subject(buffer) { described_class.immutable(data, :map_read) }

    it "populates the data" do
      expect(buffer.data).to eq(data)
    end

    it "sets the storage flags" do
      expect(buffer.storage_flags).to eq(Gloop::Buffer::Storage::MapRead)
    end

    it "creates a immutable buffer" do
      expect(buffer.immutable?).to be_true
    end
  end

  describe ".delete" do
    it "deletes buffers" do
      buffers = described_class.create(3)
      Gloop::Buffer.delete(buffers)
      aggregate_failures do
        expect(buffers[0].exists?).to be_false
        expect(buffers[1].exists?).to be_false
        expect(buffers[2].exists?).to be_false
      end
    end
  end

  describe "#delete" do
    it "deletes the buffer" do
      expect { buffer.delete }.to change(&.exists?).from(true).to(false)
    end
  end

  describe "#bind" do
    def bound_buffer
      Gloop::Buffers.array.buffer?
    end

    it "binds the buffer to a target" do
      expect { buffer.bind(:array) }.to change { bound_buffer }.to(buffer)
    end

    context "with a block" do
      it "rebinds the previous buffer after the block" do
        previous = described_class.generate
        previous.bind(:array)
        buffer.bind(:array) do
          expect(bound_buffer).to eq(buffer)
        end
        expect(bound_buffer).to eq(previous)
      end

      it "rebinds the previous buffer on error" do
        previous = described_class.generate
        previous.bind(:array)
        expect do
          buffer.bind(:array) do
            expect(bound_buffer).to eq(buffer)
            raise "oops"
          end
        end.to raise_error("oops")
        expect(bound_buffer).to eq(previous)
      end

      it "unbinds the buffer when a previous one wasn't bound" do
        described_class.none.bind(:array)
        buffer.bind(:array) do
          expect(bound_buffer).to eq(buffer)
        end
        expect(bound_buffer).to be_nil
      end
    end
  end

  describe "#usage" do
    subject { buffer.usage }

    it "retrieves the usage hints" do
      buffer.data(Bytes.empty, :dynamic_draw)
      is_expected.to eq(Gloop::Buffer::Usage::DynamicDraw)
    end
  end

  describe "#storage_flags" do
    subject { buffer.storage_flags }
    let(flags) { Gloop::Buffer::Storage.flags(MapRead, MapPersistent, MapCoherent) }
    before_each { buffer.storage(data, flags) }

    it "retrieves the storage flags" do
      is_expected.to eq(flags)
    end
  end

  describe "#data" do
    subject { buffer.data }

    it "stores data in the buffer" do
      buffer.data(data, :static_draw)
      is_expected.to eq(data)
    end

    it "makes the buffer mutable" do
      buffer.data(data)
      expect(buffer.immutable?).to be_false
    end
  end

  describe "#allocate_data" do
    it "allocates space for the buffer" do
      buffer.allocate_data(64)
      expect(buffer.size).to eq(64)
    end

    it "sets the usage hints" do
      buffer.allocate_data(64, :dynamic_draw)
      expect(buffer.usage).to eq(Gloop::Buffer::Usage::DynamicDraw)
    end

    it "makes the buffer mutable" do
      buffer.allocate_data(64)
      expect(buffer.immutable?).to be_false
    end
  end

  describe "#data=" do
    it "stores data in the buffer" do
      buffer.data = data
      expect(buffer.data).to eq(data)
    end

    it "retains the usage hint" do
      buffer.data(data, :dynamic_draw)
      buffer.data = data
      expect(buffer.usage).to eq(Gloop::Buffer::Usage::DynamicDraw)
    end

    it "makes the buffer mutable" do
      buffer.data = data
      expect(buffer.immutable?).to be_false
    end
  end

  describe "#storage" do
    it "stores data in the buffer" do
      buffer.storage(data, :none)
      expect(buffer.data).to eq(data)
    end

    it "makes the buffer immutable" do
      buffer.storage(data, :none)
      expect(buffer.immutable?).to be_true
    end
  end

  describe "#allocate_storage" do
    it "allocates space for the buffer" do
      buffer.allocate_storage(64, :none)
      expect(buffer.size).to eq(64)
    end

    it "sets the storage flags" do
      buffer.allocate_storage(64, :map_read)
      expect(buffer.storage_flags).to eq(Gloop::Buffer::Storage::MapRead)
    end

    it "makes the buffer immutable" do
      buffer.allocate_storage(64, :none)
      expect(buffer.immutable?).to be_true
    end
  end

  describe "#[]" do
    before_each { buffer.data = data }

    context "with a Range" do
      it "retrieves a subset of data from the buffer" do
        expect(buffer[1..3]).to eq(Bytes[1, 2, 3])
      end

      it "supports negative offsets" do
        expect(buffer[-5..-1]).to eq(Bytes[3, 4, 5, 6, 7])
      end

      it "raises on out-of-range values" do
        expect { buffer[-100..100] }.to raise_error(IndexError)
      end
    end

    context "with start and count" do
      it "retrieves a subset of data from the buffer" do
        expect(buffer[3, 4]).to eq(Bytes[3, 4, 5, 6])
      end

      it "supports negative offsets" do
        expect(buffer[-6, 2]).to eq(Bytes[2, 3])
      end

      it "raises on negative counts" do
        expect { buffer[-1, -2] }.to raise_error(ArgumentError)
      end

      it "raises on out-of-range values" do
        expect { buffer[-100, 100] }.to raise_error(IndexError)
      end
    end
  end

  describe "#[]?" do
    before_each { buffer.data = data }

    context "with a Range" do
      it "retrieves a subset of data from the buffer" do
        expect(buffer[1..3]?).to eq(Bytes[1, 2, 3])
      end

      it "supports negative offsets" do
        expect(buffer[-5..-1]?).to eq(Bytes[3, 4, 5, 6, 7])
      end

      it "returns nil on out-of-range values" do
        expect(buffer[-100..100]?).to be_nil
      end
    end

    context "with start and count" do
      it "retrieves a subset of data from the buffer" do
        expect(buffer[3, 4]?).to eq(Bytes[3, 4, 5, 6])
      end

      it "supports negative offsets" do
        expect(buffer[-6, 2]?).to eq(Bytes[2, 3])
      end

      it "raises on negative counts" do
        expect { buffer[-1, -2]? }.to raise_error(ArgumentError)
      end

      it "raises on out-of-range values" do
        expect(buffer[-100, 100]?).to be_nil
      end
    end
  end

  describe "#update" do
    let(sub_data) { Bytes[5, 4, 3, 2] }
    before_each { buffer.data = data }

    it "updates a subset of the buffer" do
      expect { buffer.update(2, sub_data) }.to change(&.data).to(Bytes[0, 1, 5, 4, 3, 2, 6, 7])
    end
  end

  describe "#[]=" do
    let(sub_data) { Bytes[5, 4, 3, 2] }
    before_each { buffer.data = data }

    context "with a Range" do
      it "updates a subset of the buffer" do
        expect { buffer[2..5] = sub_data }.to change(&.data).to(Bytes[0, 1, 5, 4, 3, 2, 6, 7])
      end
    end

    context "with start and count" do
      it "updates a subset of the buffer" do
        expect { buffer[2, 4] = sub_data }.to change(&.data).to(Bytes[0, 1, 5, 4, 3, 2, 6, 7])
      end
    end
  end

  describe ".copy" do
    let(buffer_a) { described_class.create }
    let(buffer_b) { described_class.create }

    before_each do
      buffer_a.data = Bytes[10, 11, 12, 13, 14, 15, 16, 17]
      buffer_b.data = Bytes[20, 21, 22, 23, 24, 25, 26, 27]
    end

    it "copies data from one buffer to another" do
      described_class.copy(buffer_a, buffer_b, 1, 2, 4)
      expect(buffer_b.data).to eq(Bytes[20, 21, 11, 12, 13, 14, 26, 27])
    end
  end

  describe "#copy_to" do
    let(buffer_a) { described_class.create }
    let(buffer_b) { described_class.create }

    before_each do
      buffer_a.data = Bytes[10, 11, 12, 13, 14, 15, 16, 17]
      buffer_b.data = Bytes[20, 21, 22, 23, 24, 25, 26, 27]
    end

    it "copies data from one buffer to another" do
      buffer_a.copy_to(buffer_b, 1, 2, 4)
      expect(buffer_b.data).to eq(Bytes[20, 21, 11, 12, 13, 14, 26, 27])
    end
  end

  describe "#copy_from" do
    let(buffer_a) { described_class.create }
    let(buffer_b) { described_class.create }

    before_each do
      buffer_a.data = Bytes[10, 11, 12, 13, 14, 15, 16, 17]
      buffer_b.data = Bytes[20, 21, 22, 23, 24, 25, 26, 27]
    end

    it "copies data from one buffer to another" do
      buffer_b.copy_from(buffer_a, 1, 2, 4)
      expect(buffer_b.data).to eq(Bytes[20, 21, 11, 12, 13, 14, 26, 27])
    end
  end

  describe "#invalidate" do
    before_each { buffer.data = data }

    specify do
      expect(&.invalidate).to_not raise_error
    end

    context "with a Range" do
      specify do
        expect(&.invalidate(2..5)).to_not raise_error
      end
    end

    context "with start and count" do
      specify do
        expect(&.invalidate(2, 4)).to_not raise_error
      end
    end
  end

  context "Labelable" do
    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end
