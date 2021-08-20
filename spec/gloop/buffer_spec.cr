require "../spec_helper"

Spectator.describe Gloop::Buffer do
  subject(buffer) { described_class.create }

  let(data) do
    Bytes.new(8) { |i| i.to_u8 }
  end

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

  describe "#usage" do
    subject { buffer.usage }

    it "retrieves the usage hints" do
      buffer.data(Bytes.empty, :dynamic_draw)
      is_expected.to eq(Gloop::Buffer::Usage::DynamicDraw)
    end
  end

  describe "#data" do
    subject { buffer.data }

    it "stores data in the buffer" do
      buffer.data(data, :static_draw)
      is_expected.to eq(data)
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
  end

  context "Labelable" do
    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end
