require "../spec_helper"

Spectator.describe Gloop::VertexArray do
  subject(vao) { described_class.create(context) }

  def current_vao
    described_class.current?(context)
  end

  describe ".create" do
    it "creates a vertex array" do
      vao = described_class.create(context)
      expect(vao.exists?).to be_true
    end
  end

  describe ".generate" do
    it "creates a vertex array" do
      vao = described_class.generate(context)
      vao.bind
      expect(vao.exists?).to be_true
    end
  end

  describe ".none" do
    subject { described_class.none(context) }

    it "is a null object" do
      expect(&.none?).to be_true
    end
  end

  describe ".delete" do
    it "deletes vertex arrays" do
      vaos = Array.new(3) { described_class.create(context) }
      described_class.delete(vaos)
      expect(vaos.map(&.exists?)).to all(be_false)
    end
  end

  describe "#delete" do
    it "deletes the vertex array" do
      expect { vao.delete }.to change(&.exists?).from(true).to(false)
    end
  end

  describe "#bind" do
    before_each { described_class.unbind(context) }

    it "binds a vertex array to the target" do
      expect(&.bind).to change { current_vao }.from(nil).to(vao)
    end

    context "with a block" do
      it "rebinds the previous vertex array after the block" do
        previous = Gloop::VertexArray.generate(context)
        previous.bind
        vao.bind do
          expect(current_vao).to eq(vao)
        end
        expect(current_vao).to eq(previous)
      end

      it "rebinds the previous vertex array on error" do
        previous = Gloop::VertexArray.generate(context)
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
      expect { described_class.unbind(context) }.to change { current_vao }.from(vao).to(nil)
    end
  end

  describe "#element_array_buffer?" do
    subject { vao.element_array_buffer? }

    context "with a buffer bound" do
      let(buffer) { Gloop::Buffer.create(context) }

      around_each do |example|
        vao.bind do
          buffer.bind(:element_array)
          example.run
        end
      end

      it "is the currently bound EBO" do
        is_expected.to eq(buffer)
      end
    end

    it "is nil" do
      is_expected.to be_nil
    end
  end

  describe "#element_array_buffer" do
    subject { vao.element_array_buffer }

    context "with a buffer bound" do
      let(buffer) { Gloop::Buffer.create(context) }

      around_each do |example|
        vao.bind do
          buffer.bind(:element_array)
          example.run
        end
      end

      it "is the currently bound EBO" do
        is_expected.to eq(buffer)
      end
    end

    it "is a null-object buffer" do
      is_expected.to be_none
    end
  end

  describe "#element_array_buffer=" do
    let(buffer) { Gloop::Buffer.create(context) }

    it "sets the EBO" do
      expect { vao.element_array_buffer = buffer }.to change(&.element_array_buffer?).from(nil).to(buffer)
    end
  end

  describe "#attributes" do
    subject { vao.attributes }

    it "is a collection of attributes" do
      is_expected.to be_an(Enumerable(Gloop::VertexArray::Attribute))
    end
  end

  describe "#bind_vertex_buffer" do
    let(slot) { 0_u32 }
    let(buffer) { Gloop::Buffer.create(context) }
    let(attribute) { Gloop::VertexArray::Attribute.new(context, vao.name, 0) }
    let(binding) { Gloop::VertexArray::Binding.new(context, vao.name, slot) }

    before_each do
      attribute.enable
      attribute.specify_format(2, :float32, false, 24)
    end

    it "sets the stride and offset" do
      vao.bind_attribute(attribute, slot)
      vao.bind_vertex_buffer(buffer, slot, 64, 256)
      expect(binding.offset).to eq(64)
      expect(binding.stride).to eq(256)
    end
  end

  describe "#bind_attribute" do
    let(slot) { 0_u32 }
    let(attribute) { Gloop::VertexArray::Attribute.new(context, vao.name, 0) }
    let(binding) { Gloop::VertexArray::Binding.new(context, vao.name, slot) }

    before_each do
      attribute.enable
      attribute.specify_format(2, :float32, false, 24)
    end

    it "sets the stride" do
      vao.bind_attribute(attribute, slot)
      expect(binding.stride).to eq(16) # 2 x sizeof(Float32)
    end
  end

  describe "#bindings" do
    subject { vao.bindings }

    it "is a collection of binding slots" do
      is_expected.to be_an(Enumerable(Gloop::VertexArray::Binding))
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
  subject { context }
  let(vao) { context.create_vertex_array }

  describe "#create_vertex_array" do
    it "creates a vertex array" do
      vao = context.create_vertex_array
      expect(vao.exists?).to be_true
    ensure
      vao.try(&.delete)
    end
  end

  describe "#create_vertex_arrays" do
    it "creates multiple vertex arrays" do
      vaos = context.create_vertex_arrays(3)
      expect(vaos.map(&.exists?)).to all(be_true)
    ensure
      vaos.try(&.delete)
    end
  end

  describe "#generate_vertex_array" do
    it "creates a vertex array" do
      vao = context.generate_vertex_array
      vao.bind
      expect(vao.exists?).to be_true
    ensure
      vao.try(&.delete)
    end
  end

  describe "#generate_vertex_arrays" do
    it "creates multiple vertex arrays" do
      vaos = context.generate_vertex_arrays(3)
      vaos.each(&.bind)
      expect(vaos.map(&.exists?)).to all(be_true)
    ensure
      vaos.try(&.delete)
    end
  end

  describe "#vertex_array?" do
    subject { context.vertex_array? }

    it "is the currently bound vertex array" do
      vao.bind
      is_expected.to eq(vao)
    end

    it "is nil when no vertex array is bound" do
      context.unbind_vertex_array
      is_expected.to be_nil
    end
  end

  describe "#vertex_array" do
    subject { context.vertex_array }

    it "is the currently bound vertex array" do
      vao.bind
      is_expected.to eq(vao)
    end

    it "is the null object when no vertex array is bound" do
      context.unbind_vertex_array
      is_expected.to be_none
    end
  end

  describe "#unbind_vertex_array" do
    it "unbinds the current vertex array" do
      vao.bind
      expect { context.unbind_vertex_array }.to change(&.vertex_array?).from(vao).to(nil)
    end
  end
end

Spectator.describe Gloop::VertexArrayList do
  subject(list) { described_class.create(context, 3) }

  describe ".create" do
    it "creates multiple vertex arrays" do
      vaos = described_class.create(context, 3)
      expect(vaos.map(&.exists?)).to all(be_true)
    ensure
      vaos.try(&.delete)
    end
  end

  describe ".generate" do
    it "creates multiple vertex arrays" do
      vaos = described_class.generate(context, 3)
      vaos.each(&.bind)
      expect(vaos.map(&.exists?)).to all(be_true)
    ensure
      vaos.try(&.delete)
    end
  end

  describe "#delete" do
    it "deletes all vertex arrays" do
      list.delete
      expect(list.map(&.exists?)).to all(be_false)
    end
  end
end
