require_relative 'spec_helper'

describe Yample::Build do
  describe ".new" do
    context "w/o an argument" do
      it "raise argument error" do
        expect { should }.to raise_error(ArgumentError)
      end
    end

    context "w/ yaml string" do
      subject { Yample::Build.new ~<<-EOS }
        item1:
          title: book1
        EOS
      its(:yaml) { should == {'item1' => {'title' => 'book1'}} }
    end

    context "w/ yaml file but not exist" do
      subject { Yample::Build.new 'item.yaml' }
      it "raise file not found error" do
        expect { should }.to raise_error(Errno::ENOENT)
      end
    end

    context "w/ yaml file" do
      include FakeFS::SpecHelpers
      FakeFS do
        File.open('item.yaml', 'w') do |f|
          f.puts ~<<-EOS
            item1:
              title: book1
            EOS
        end
        subject { Yample::Build.new 'item.yaml' }
        its(:yaml) { should == {'item1' => {'title' => 'book1'}} }
      end
    end
  end

  describe "#data" do
    subject { Yample::Build.new(~<<-EOS).data }
      item1:
        title: book1
        price: 100
      item2:
        title: book2
        price: 200
      EOS
    it { should be_instance_of(Array) }
    its(:first) { should be_instance_of(Hashie::Mash) }
    its('first.title') { should eq 'book1' }
    its('first.price') { should be 100 }
    its('last.title') { should eq 'book2' }
    its('last.price') { should be 200 }
  end

end