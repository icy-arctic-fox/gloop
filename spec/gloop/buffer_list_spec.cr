require "../spec_helper"

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
