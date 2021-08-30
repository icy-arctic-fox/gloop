require "../spec_helper"

Spectator.describe Gloop::VertexArray do
  subject(vao) { described_class.create }

  def current_vao
    described_class.current?
  end

  describe ".create" do
    it "creates a vertex array" do
      vao = described_class.create
      expect(vao.exists?).to be_true
    end

    it "creates multiple vertex arrays" do
      vaos = described_class.create(3)
      aggregate_failures do
        expect(vaos[0].exists?).to be_true
        expect(vaos[1].exists?).to be_true
        expect(vaos[2].exists?).to be_true
      end
    end
  end

  describe ".generate" do
    it "creates a vertex array" do
      vao = described_class.generate
      vao.bind
      expect(vao.exists?).to be_true
    end

    it "creates multiple vertex arrays" do
      vaos = described_class.generate(3)
      aggregate_failures do
        3.times do |i|
          vaos[i].bind
          expect(vaos[i].exists?).to be_true
        end
      end
    end
  end

  describe ".none" do
    subject { described_class.none }

    it "is a null object" do
      expect(&.none?).to be_true
    end
  end

  describe ".delete" do
    it "deletes vertex arrays" do
      vaos = described_class.create(3)
      Gloop::VertexArray.delete(vaos)
      aggregate_failures do
        expect(vaos[0].exists?).to be_false
        expect(vaos[1].exists?).to be_false
        expect(vaos[2].exists?).to be_false
      end
    end
  end

  describe "#delete" do
    it "deletes the vertex array" do
      expect { vao.delete }.to change(&.exists?).from(true).to(false)
    end
  end

  describe "#bind" do
    before_each { described_class.unbind }

    it "binds a vertex array to the target" do
      expect(&.bind).to change { current_vao }.from(nil).to(vao)
    end

    context "with a block" do
      it "rebinds the previous vertex array after the block" do
        previous = Gloop::VertexArray.generate
        previous.bind
        vao.bind do
          expect(current_vao).to eq(vao)
        end
        expect(current_vao).to eq(previous)
      end

      it "rebinds the previous vertex array on error" do
        previous = Gloop::VertexArray.generate
        previous.bind
        expect do
          vao.bind do
            expect(current_vao).to eq(vao)
            raise "oops"
          end
        end.to raise_error("oops")
        expect(current_vao).to eq(previous)
      end

      it "unbinds the vertex array when a previous one wasn't bound" do
        vao.bind do
          expect(current_vao).to eq(vao)
        end
        expect(current_vao).to be_nil
      end
    end
  end

  describe ".unbind" do
    before_each { vao.bind }

    it "removes a previously bound vertex array" do
      expect { described_class.unbind }.to change { current_vao }.from(vao).to(nil)
    end
  end

  context "Labelable" do
    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end
