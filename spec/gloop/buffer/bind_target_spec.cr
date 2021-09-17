require "../../spec_helper"

Spectator.describe Gloop::Buffer::BindTarget do
  subject(buffer) { Gloop::Buffer.generate(context) }
  subject(target) { Gloop::Buffers.array }
  let(data) { Bytes.new(8, &.to_u8) }
  before_each { target.bind(buffer) }

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

  describe ".copy" do
    let(buffer_a) { Gloop::Buffer.generate }
    let(buffer_b) { Gloop::Buffer.generate }
    let(target_a) { Gloop::Buffers.copy_read }
    let(target_b) { Gloop::Buffers.copy_write }

    before_each do
      target_a.bind(buffer_a)
      target_b.bind(buffer_b)
      target_a.data = Bytes[10, 11, 12, 13, 14, 15, 16, 17]
      target_b.data = Bytes[20, 21, 22, 23, 24, 25, 26, 27]
    end

    it "copies data from one buffer to another" do
      described_class.copy(target_a, target_b, 1, 2, 4)
      expect(target_b.data).to eq(Bytes[20, 21, 11, 12, 13, 14, 26, 27])
    end
  end

  describe "#copy_to" do
    let(buffer_a) { Gloop::Buffer.generate }
    let(buffer_b) { Gloop::Buffer.generate }
    let(target_a) { Gloop::Buffers.copy_read }
    let(target_b) { Gloop::Buffers.copy_write }

    before_each do
      target_a.bind(buffer_a)
      target_b.bind(buffer_b)
      target_a.data = Bytes[10, 11, 12, 13, 14, 15, 16, 17]
      target_b.data = Bytes[20, 21, 22, 23, 24, 25, 26, 27]
    end

    it "copies data from one buffer to another" do
      target_a.copy_to(target_b, 1, 2, 4)
      expect(target_b.data).to eq(Bytes[20, 21, 11, 12, 13, 14, 26, 27])
    end
  end

  describe "#copy_from" do
    let(buffer_a) { Gloop::Buffer.generate }
    let(buffer_b) { Gloop::Buffer.generate }
    let(target_a) { Gloop::Buffers.copy_read }
    let(target_b) { Gloop::Buffers.copy_write }

    before_each do
      target_a.bind(buffer_a)
      target_b.bind(buffer_b)
      target_a.data = Bytes[10, 11, 12, 13, 14, 15, 16, 17]
      target_b.data = Bytes[20, 21, 22, 23, 24, 25, 26, 27]
    end

    it "copies data from one buffer to another" do
      target_b.copy_from(target_a, 1, 2, 4)
      expect(target_b.data).to eq(Bytes[20, 21, 11, 12, 13, 14, 26, 27])
    end
  end

  describe "#map" do
    let(data) { Bytes[10, 20, 30, 40, 50, 60, 70, 80] }
    before_each { target.data = data }

    it "maps the buffer into client space" do
      bytes = target.map(:read_write)
      expect(bytes).to eq(data)
    ensure
      target.unmap
    end

    it "sets the size correctly" do
      bytes = target.map(:read_write)
      expect(bytes.size).to eq(data.bytesize)
    ensure
      target.unmap
    end

    context "with read-only access" do
      it "sets the slice as read-only" do
        bytes = target.map(:read_only)
        expect(bytes).to be_read_only
      ensure
        target.unmap
      end
    end

    context "with write access" do
      it "sets the slice as writable" do
        bytes = target.map(:write_only)
        expect(bytes).to_not be_read_only
      ensure
        target.unmap
      end

      it "stores changes in the buffer" do
        bytes = target.map(:write_only)
        bytes[3] = 42_u8
        expect(target.unmap).to be_true, "Unmap failed - buffer corrupt"
        expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
      end
    end

    context "with a Range" do
      let(range) { 1..6 }
      let(subdata) { data[range] }
      let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }

      it "maps the buffer into client space" do
        bytes = target.map(access_mask, range)
        expect(bytes).to eq(subdata)
      ensure
        target.unmap
      end

      it "sets the size correctly" do
        bytes = target.map(access_mask, range)
        expect(bytes.size).to eq(subdata.bytesize)
      ensure
        target.unmap
      end

      context "with read-only access" do
        it "sets the slice as read-only" do
          bytes = target.map(:read, range)
          expect(bytes).to be_read_only
        ensure
          target.unmap
        end
      end

      context "with write access" do
        it "sets the slice as writable" do
          bytes = target.map(:write, range)
          expect(bytes).to_not be_read_only
        ensure
          target.unmap
        end

        it "stores changes in the buffer" do
          bytes = target.map(:write, range)
          bytes[2] = 42_u8
          expect(target.unmap).to be_true, "Unmap failed - buffer corrupt"
          expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
        end
      end
    end

    context "with a start and count" do
      let(start) { 1 }
      let(count) { 6 }
      let(subdata) { data[start, count] }
      let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }

      it "maps the buffer into client space" do
        bytes = target.map(access_mask, start, count)
        expect(bytes).to eq(subdata)
      ensure
        target.unmap
      end

      it "sets the size correctly" do
        bytes = target.map(access_mask, start, count)
        expect(bytes.size).to eq(subdata.bytesize)
      ensure
        target.unmap
      end

      context "with read-only access" do
        it "sets the slice as read-only" do
          bytes = target.map(:read, start, count)
          expect(bytes).to be_read_only
        ensure
          target.unmap
        end
      end

      context "with write access" do
        it "sets the slice as writable" do
          bytes = target.map(:write, start, count)
          expect(bytes).to_not be_read_only
        ensure
          target.unmap
        end

        it "stores changes in the buffer" do
          bytes = target.map(:write, start, count)
          bytes[2] = 42_u8
          expect(target.unmap).to be_true, "Unmap failed - buffer corrupt"
          expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
        end
      end
    end

    context "with a block" do
      it "maps the buffer into client space" do
        target.map(:read_write) do |bytes|
          expect(bytes).to eq(data)
        end
      end

      it "sets the size correctly" do
        target.map(:read_write) do |bytes|
          expect(bytes.size).to eq(data.bytesize)
        end
      end

      it "unmaps the buffer afterwards" do
        target.map(:read_write) do
          is_expected.to be_mapped
        end
        is_expected.to_not be_mapped
      end

      it "unmaps the buffer on error" do
        expect do
          target.map(:read_write) do
            raise "oops"
          end
        end.to raise_error("oops")
        is_expected.to_not be_mapped
      end

      context "with read-only access" do
        it "sets the slice as read-only" do
          target.map(:read_only) do |bytes|
            expect(bytes).to be_read_only
          end
        end
      end

      context "with write access" do
        it "sets the slice as writable" do
          target.map(:write_only) do |bytes|
            expect(bytes).to_not be_read_only
          end
        end

        it "stores changes in the buffer" do
          unmap = target.map(:write_only) do |bytes|
            bytes[3] = 42_u8
          end
          expect(unmap).to be_true, "Unmap failed - buffer corrupt"
          expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
        end
      end

      context "with a Range" do
        let(range) { 1..6 }
        let(subdata) { data[range] }
        let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }

        it "maps the buffer into client space" do
          target.map(access_mask, range) do |bytes|
            expect(bytes).to eq(subdata)
          end
        end

        it "sets the size correctly" do
          target.map(access_mask, range) do |bytes|
            expect(bytes.size).to eq(subdata.bytesize)
          end
        end

        it "unmaps the buffer afterwards" do
          target.map(access_mask, range) do
            is_expected.to be_mapped
          end
          is_expected.to_not be_mapped
        end

        it "unmaps the buffer on error" do
          expect do
            target.map(access_mask, range) do
              raise "oops"
            end
          end.to raise_error("oops")
          is_expected.to_not be_mapped
        end

        context "with read-only access" do
          it "sets the slice as read-only" do
            target.map(:read, range) do |bytes|
              expect(bytes).to be_read_only
            end
          end
        end

        context "with write access" do
          it "sets the slice as writable" do
            target.map(:write, range) do |bytes|
              expect(bytes).to_not be_read_only
            end
          end

          it "stores changes in the buffer" do
            unmap = target.map(:write, range) do |bytes|
              bytes[2] = 42_u8
            end
            expect(unmap).to be_true, "Unmap failed - buffer corrupt"
            expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
          end
        end
      end

      context "with a start and count" do
        let(start) { 1 }
        let(count) { 6 }
        let(subdata) { data[start, count] }
        let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }

        it "maps the buffer into client space" do
          target.map(access_mask, start, count) do |bytes|
            expect(bytes).to eq(subdata)
          end
        end

        it "sets the size correctly" do
          target.map(access_mask, start, count) do |bytes|
            expect(bytes.size).to eq(subdata.bytesize)
          end
        end

        it "unmaps the buffer afterwards" do
          target.map(access_mask, start, count) do
            is_expected.to be_mapped
          end
          is_expected.to_not be_mapped
        end

        it "unmaps the buffer on error" do
          expect do
            target.map(access_mask, start, count) do
              raise "oops"
            end
          end.to raise_error("oops")
          is_expected.to_not be_mapped
        end

        context "with read-only access" do
          it "sets the slice as read-only" do
            target.map(:read, start, count) do |bytes|
              expect(bytes).to be_read_only
            end
          end
        end

        context "with write access" do
          it "sets the slice as writable" do
            target.map(:write, start, count) do |bytes|
              expect(bytes).to_not be_read_only
            end
          end

          it "stores changes in the buffer" do
            unmap = target.map(:write, start, count) do |bytes|
              bytes[2] = 42_u8
            end
            expect(unmap).to be_true, "Unmap failed - buffer corrupt"
            expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
          end
        end
      end
    end
  end

  describe "#unmap" do
    let(data) { Bytes[10, 20, 30, 40, 50, 60, 70, 80] }
    before_each do
      target.data = data
      target.map(:read_only)
    end

    it "unmaps the buffer" do
      expect { target.unmap }.to change(&.mapped?).from(true).to(false)
    end
  end

  describe "#flush" do
    let(data) { Bytes[10, 20, 30, 40, 50, 60, 70, 80] }
    let(storage_flags) { Gloop::Buffer::Storage.flags(MapWrite, MapPersistent) }
    let(buffer) { Gloop::Buffer.immutable(data, storage_flags) }
    let(access_mask) { Gloop::Buffer::AccessMask.flags(Write, Persistent, FlushExplicit) }

    before_each { @bytes = target.map(access_mask, 1..6) }
    after_each { target.unmap }

    private getter bytes : Bytes = Bytes.empty

    it "publishes changed data" do
      bytes[2] = 42_u8
      target.flush
      expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
    end

    context "with a start and count" do
      it "publishes changed data" do
        bytes[2] = 42_u8
        target.flush(2, 1)
        expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
      end
    end

    context "with a Range" do
      it "publishes changed data" do
        bytes[2] = 42_u8
        target.flush(2..3)
        expect(target.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
      end
    end
  end

  describe "#mapping?" do
    it "returns nil when a buffer isn't mapped" do
      expect(&.mapping?).to be_nil
    end
  end

  describe "#mapping" do
    it "raises when a buffer isn't mapped" do
      expect { target.mapping }.to raise_error(NilAssertionError, /map/)
    end
  end
end
