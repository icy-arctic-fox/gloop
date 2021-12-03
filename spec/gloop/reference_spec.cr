require "weak_ref"
require "../spec_helper"

Spectator.describe Gloop::Reference do
  it "generates an object" do
    ref = Gloop::Reference(Gloop::Buffer).generate(context)
    ref.bind(Gloop::Buffer::Target::Array)
    expect(ref.exists?).to be_true
  end

  it "creates an object" do
    ref = Gloop::Reference(Gloop::Buffer).create(context)
    expect(ref.exists?).to be_true
  end

  it "deletes unreferenced objects" do
    {% if flag?(:release) %}
      skip "WeakRef appears to not work correctly in release mode - https://github.com/crystal-lang/crystal/issues/10469"
    {% end %}
    ref = WeakRef.new(Gloop::Reference(Gloop::Buffer).create(context))
    GC.collect
    expect(ref.value).to be_nil
  end
end
