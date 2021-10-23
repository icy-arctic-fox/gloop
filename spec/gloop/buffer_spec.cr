require "../spec_helper"

Spectator.describe Gloop::Buffer do
  subject(buffer) { described_class.create(context) }
  let(data) { Bytes.new(8, &.to_u8) }

  describe ".create" do
    it "creates a buffer" do
      buffer = described_class.create(context)
      expect(&.exists?).to be_true
    ensure
      buffer.try(&.delete)
    end

    it "creates multiple buffers" do
      buffers = described_class.create(context, 3)
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
      buffer = described_class.generate(context)
      buffer.bind(:array)
      expect(buffer.exists?).to be_true
    ensure
      buffer.try(&.delete)
    end

    it "creates multiple buffers" do
      buffers = described_class.generate(context, 3)
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
    subject { described_class.none(context) }

    it "is a null object" do
      expect(&.none?).to be_true
    end
  end

  describe ".delete" do
    it "deletes buffers" do
      buffers = described_class.create(context, 3)
      described_class.delete(buffers)
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
      context.buffers.array.buffer?
    end

    it "binds the buffer to a target" do
      expect { buffer.bind(:array) }.to change { bound_buffer }.to(buffer)
    end

    context "with a block" do
      it "rebinds the previous buffer after the block" do
        previous = described_class.generate(context)
        previous.bind(:array)
        buffer.bind(:array) do
          expect(bound_buffer).to eq(buffer)
        end
        expect(bound_buffer).to eq(previous)
      end

      it "rebinds the previous buffer on error" do
        previous = described_class.generate(context)
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
        described_class.none(context).bind(:array)
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

      it "raises on out-of-range values" do
        expect { buffer[-100..100] }.to raise_error(Gloop::InvalidValueError)
      end
    end

    context "with start and count" do
      it "retrieves a subset of data from the buffer" do
        expect(buffer[3, 4]).to eq(Bytes[3, 4, 5, 6])
      end

      it "raises on negative counts" do
        expect { buffer[-1, -2] }.to raise_error(ArgumentError)
      end

      it "raises on out-of-range values" do
        expect { buffer[-100, 100] }.to raise_error(Gloop::InvalidValueError)
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
    let(buffer_a) { described_class.create(context) }
    let(buffer_b) { described_class.create(context) }

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
    let(buffer_a) { described_class.create(context) }
    let(buffer_b) { described_class.create(context) }

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
    let(buffer_a) { described_class.create(context) }
    let(buffer_b) { described_class.create(context) }

    before_each do
      buffer_a.data = Bytes[10, 11, 12, 13, 14, 15, 16, 17]
      buffer_b.data = Bytes[20, 21, 22, 23, 24, 25, 26, 27]
    end

    it "copies data from one buffer to another" do
      buffer_b.copy_from(buffer_a, 1, 2, 4)
      expect(buffer_b.data).to eq(Bytes[20, 21, 11, 12, 13, 14, 26, 27])
    end
  end

  describe "#clear" do
    before_each { buffer.data = Bytes[0, 1, 2, 3, 4, 5, 6, 7] }

    it "sets the contents of the buffer to zero" do
      buffer.clear
      expect(&.data).to eq(Bytes[0, 0, 0, 0, 0, 0, 0, 0])
    end

    context "with a single value" do
      it "sets the contents of the buffer (Int8)" do
        buffer.clear(3_i8)
        expect(&.data).to eq(Bytes[3, 3, 3, 3, 3, 3, 3, 3])
      end

      it "sets the contents of the buffer (UInt8)" do
        buffer.clear(200_u8)
        expect(&.data).to eq(Bytes[200, 200, 200, 200, 200, 200, 200, 200])
      end

      it "sets the contents of the buffer (Int16)" do
        buffer.clear(258_i16)
        expect(&.data).to eq(Bytes[2, 1, 2, 1, 2, 1, 2, 1])
      end

      it "sets the contents of the buffer (UInt16)" do
        buffer.clear(4128_u16)
        expect(&.data).to eq(Bytes[32, 16, 32, 16, 32, 16, 32, 16])
      end

      it "sets the contents of the buffer (Int32)" do
        buffer.clear(16909060_i32)
        expect(&.data).to eq(Bytes[4, 3, 2, 1, 4, 3, 2, 1])
      end

      it "sets the contents of the buffer (UInt32)" do
        buffer.clear(270544960_u32)
        expect(&.data).to eq(Bytes[64, 48, 32, 16, 64, 48, 32, 16])
      end

      it "sets the contents of the buffer (Float32)" do
        buffer.clear(1.234_f32)
        expect(&.data).to eq(Bytes[182, 243, 157, 63, 182, 243, 157, 63])
      end
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

  describe "#map" do
    let(data) { Bytes[10, 20, 30, 40, 50, 60, 70, 80] }
    before_each { buffer.data = data }

    it "maps the buffer into client space" do
      bytes = buffer.map(:read_write)
      expect(bytes).to eq(data)
    ensure
      buffer.unmap
    end

    it "sets the size correctly" do
      bytes = buffer.map(:read_write)
      expect(bytes.size).to eq(data.bytesize)
    ensure
      buffer.unmap
    end

    context "with read-only access" do
      it "sets the slice as read-only" do
        bytes = buffer.map(:read_only)
        expect(bytes).to be_read_only
      ensure
        buffer.unmap
      end
    end

    context "with write access" do
      it "sets the slice as writable" do
        bytes = buffer.map(:write_only)
        expect(bytes).to_not be_read_only
      ensure
        buffer.unmap
      end

      it "stores changes in the buffer" do
        bytes = buffer.map(:write_only)
        bytes[3] = 42_u8
        expect(buffer.unmap).to be_true, "Unmap failed - buffer corrupt"
        expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
      end
    end

    context "with a Range" do
      let(range) { 1..6 }
      let(subdata) { data[range] }
      let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }

      it "maps the buffer into client space" do
        bytes = buffer.map(access_mask, range)
        expect(bytes).to eq(subdata)
      ensure
        buffer.unmap
      end

      it "sets the size correctly" do
        bytes = buffer.map(access_mask, range)
        expect(bytes.size).to eq(subdata.bytesize)
      ensure
        buffer.unmap
      end

      context "with read-only access" do
        it "sets the slice as read-only" do
          bytes = buffer.map(:read, range)
          expect(bytes).to be_read_only
        ensure
          buffer.unmap
        end
      end

      context "with write access" do
        it "sets the slice as writable" do
          bytes = buffer.map(:write, range)
          expect(bytes).to_not be_read_only
        ensure
          buffer.unmap
        end

        it "stores changes in the buffer" do
          bytes = buffer.map(:write, range)
          bytes[2] = 42_u8
          expect(buffer.unmap).to be_true, "Unmap failed - buffer corrupt"
          expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
        end
      end
    end

    context "with a start and count" do
      {% if flag?(:x86_64) %}
        let(start) { 1_i64 }
        let(count) { 6_i64 }
      {% else %}
        let(start) { 1_i32 }
        let(count) { 6_i32 }
      {% end %}
      let(subdata) { data[start, count] }
      let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }

      it "maps the buffer into client space" do
        bytes = buffer.map(access_mask, start, count)
        expect(bytes).to eq(subdata)
      ensure
        buffer.unmap
      end

      it "sets the size correctly" do
        bytes = buffer.map(access_mask, start, count)
        expect(bytes.size).to eq(subdata.bytesize)
      ensure
        buffer.unmap
      end

      context "with read-only access" do
        it "sets the slice as read-only" do
          bytes = buffer.map(:read, start, count)
          expect(bytes).to be_read_only
        ensure
          buffer.unmap
        end
      end

      context "with write access" do
        it "sets the slice as writable" do
          bytes = buffer.map(:write, start, count)
          expect(bytes).to_not be_read_only
        ensure
          buffer.unmap
        end

        it "stores changes in the buffer" do
          bytes = buffer.map(:write, start, count)
          bytes[2] = 42_u8
          expect(buffer.unmap).to be_true, "Unmap failed - buffer corrupt"
          expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
        end
      end
    end

    context "with a block" do
      it "maps the buffer into client space" do
        buffer.map(:read_write) do |bytes|
          expect(bytes).to eq(data)
        end
      end

      it "sets the size correctly" do
        buffer.map(:read_write) do |bytes|
          expect(bytes.size).to eq(data.bytesize)
        end
      end

      it "unmaps the buffer afterwards" do
        buffer.map(:read_write) do
          is_expected.to be_mapped
        end
        is_expected.to_not be_mapped
      end

      it "unmaps the buffer on error" do
        expect do
          buffer.map(:read_write) do
            raise "oops"
          end
        end.to raise_error("oops")
        is_expected.to_not be_mapped
      end

      context "with read-only access" do
        it "sets the slice as read-only" do
          buffer.map(:read_only) do |bytes|
            expect(bytes).to be_read_only
          end
        end
      end

      context "with write access" do
        it "sets the slice as writable" do
          buffer.map(:write_only) do |bytes|
            expect(bytes).to_not be_read_only
          end
        end

        it "stores changes in the buffer" do
          unmap = buffer.map(:write_only) do |bytes|
            bytes[3] = 42_u8
          end
          expect(unmap).to be_true, "Unmap failed - buffer corrupt"
          expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
        end
      end

      context "with a Range" do
        let(range) { 1..6 }
        let(subdata) { data[range] }
        let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }

        it "maps the buffer into client space" do
          buffer.map(access_mask, range) do |bytes|
            expect(bytes).to eq(subdata)
          end
        end

        it "sets the size correctly" do
          buffer.map(access_mask, range) do |bytes|
            expect(bytes.size).to eq(subdata.bytesize)
          end
        end

        it "unmaps the buffer afterwards" do
          buffer.map(access_mask, range) do
            is_expected.to be_mapped
          end
          is_expected.to_not be_mapped
        end

        it "unmaps the buffer on error" do
          expect do
            buffer.map(access_mask, range) do
              raise "oops"
            end
          end.to raise_error("oops")
          is_expected.to_not be_mapped
        end

        context "with read-only access" do
          it "sets the slice as read-only" do
            buffer.map(:read, range) do |bytes|
              expect(bytes).to be_read_only
            end
          end
        end

        context "with write access" do
          it "sets the slice as writable" do
            buffer.map(:write, range) do |bytes|
              expect(bytes).to_not be_read_only
            end
          end

          it "stores changes in the buffer" do
            unmap = buffer.map(:write, range) do |bytes|
              bytes[2] = 42_u8
            end
            expect(unmap).to be_true, "Unmap failed - buffer corrupt"
            expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
          end
        end
      end

      context "with a start and count" do
        {% if flag?(:x86_64) %}
          let(start) { 1_i64 }
          let(count) { 6_i64 }
        {% else %}
          let(start) { 1_i32 }
          let(count) { 6_i32 }
        {% end %}
        let(subdata) { data[start, count] }
        let(access_mask) { Gloop::Buffer::AccessMask.flags(Read, Write) }

        it "maps the buffer into client space" do
          buffer.map(access_mask, start, count) do |bytes|
            expect(bytes).to eq(subdata)
          end
        end

        it "sets the size correctly" do
          buffer.map(access_mask, start, count) do |bytes|
            expect(bytes.size).to eq(subdata.bytesize)
          end
        end

        it "unmaps the buffer afterwards" do
          buffer.map(access_mask, start, count) do
            is_expected.to be_mapped
          end
          is_expected.to_not be_mapped
        end

        it "unmaps the buffer on error" do
          expect do
            buffer.map(access_mask, start, count) do
              raise "oops"
            end
          end.to raise_error("oops")
          is_expected.to_not be_mapped
        end

        context "with read-only access" do
          it "sets the slice as read-only" do
            buffer.map(:read, start, count) do |bytes|
              expect(bytes).to be_read_only
            end
          end
        end

        context "with write access" do
          it "sets the slice as writable" do
            buffer.map(:write, start, count) do |bytes|
              expect(bytes).to_not be_read_only
            end
          end

          it "stores changes in the buffer" do
            unmap = buffer.map(:write, start, count) do |bytes|
              bytes[2] = 42_u8
            end
            expect(unmap).to be_true, "Unmap failed - buffer corrupt"
            expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
          end
        end
      end
    end
  end

  describe "#unmap" do
    let(data) { Bytes[10, 20, 30, 40, 50, 60, 70, 80] }
    before_each do
      buffer.data = data
      buffer.map(:read_only)
    end

    it "unmaps the buffer" do
      expect { buffer.unmap }.to change(&.mapped?).from(true).to(false)
    end
  end

  describe "#flush" do
    let(data) { Bytes[10, 20, 30, 40, 50, 60, 70, 80] }
    let(storage_flags) { Gloop::Buffer::Storage.flags(MapWrite, MapPersistent) }
    let(buffer) { described_class.create(context).tap(&.storage(data, storage_flags)) }
    let(access_mask) { Gloop::Buffer::AccessMask.flags(Write, Persistent, FlushExplicit) }

    before_each { @bytes = buffer.map(access_mask, 1..6) }
    after_each { buffer.unmap }

    private getter bytes : Bytes = Bytes.empty

    it "publishes changed data" do
      bytes[2] = 42_u8
      buffer.flush
      expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
    end

    context "with a start and count" do
      it "publishes changed data" do
        bytes[2] = 42_u8
        buffer.flush(2, 1)
        expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
      end
    end

    context "with a Range" do
      it "publishes changed data" do
        bytes[2] = 42_u8
        buffer.flush(2..3)
        expect(buffer.data).to eq(Bytes[10, 20, 30, 42, 50, 60, 70, 80])
      end
    end
  end

  describe "#mapping?" do
    it "returns nil when the buffer isn't mapped" do
      expect(&.mapping?).to be_nil
    end
  end

  describe "#mapping" do
    it "raises when the buffer isn't mapped" do
      expect { buffer.mapping }.to raise_error(NilAssertionError, /map/)
    end
  end

  context "Labelable" do
    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end

Spectator.describe Gloop::Context do
  describe "#create_buffer" do
    it "creates a buffer" do
      buffer = context.create_buffer
      expect(buffer.exists?).to be_true
    ensure
      buffer.try(&.delete)
    end
  end

  describe "#create_buffers" do
    it "creates multiple buffers" do
      buffers = context.create_buffers(3)
      aggregate_failures do
        expect(buffers[0].exists?).to be_true
        expect(buffers[1].exists?).to be_true
        expect(buffers[2].exists?).to be_true
      end
    ensure
      buffers.delete if buffers
    end
  end

  describe "#generate_buffer" do
    it "creates a buffer" do
      buffer = context.generate_buffer
      buffer.bind(:array)
      expect(buffer.exists?).to be_true
    ensure
      buffer.try(&.delete)
    end
  end

  describe "#generate_buffers" do
    it "creates multiple buffers" do
      buffers = context.generate_buffers(3)
      aggregate_failures do
        3.times do |i|
          buffers[i].bind(:array)
          expect(buffers[i].exists?).to be_true
        end
      end
    ensure
      buffers.delete if buffers
    end
  end
end

Spectator.describe Gloop::BufferList do
  subject(list) { Gloop::Buffer.create(context, 3) }

  it "holds buffers" do
    is_expected.to be_an(Indexable(Gloop::Buffer))
    expect(&.size).to eq(3)
    aggregate_failures "buffers" do
      expect(list[0]).to be_a(Gloop::Buffer)
      expect(list[1]).to be_a(Gloop::Buffer)
      expect(list[2]).to be_a(Gloop::Buffer)
    end
  end

  describe "#delete" do
    it "deletes all buffers" do
      list.delete
      aggregate_failures "buffers" do
        list.each do |buffer|
          expect(buffer.exists?).to be_false
        end
      end
    end
  end
end
