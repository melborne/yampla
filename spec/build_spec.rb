require_relative 'spec_helper'

describe Yampla::Build do
  before do
    @yml = ~<<-EOS
      item1:
        title: book1
        price: 100
      item2:
        title: book2
        price: 200
      EOS
  end
  describe ".new" do
    context "w/o an argument" do
      it "raise argument error" do
        expect { should }.to raise_error(ArgumentError)
      end
    end
    context "w/ yaml string" do
      subject { Yampla::Build.new @yml }
      it { subject.instance_variable_get(:@yaml).should ==
                {'item1' => {'title' => 'book1', 'price' => 100},
                 'item2' => {'title' => 'book2', 'price' => 200}}
      }
    end
    context "w/ yaml file but not exist" do
      subject { Yampla::Build.new 'item.yaml' }
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
        subject { Yampla::Build.new 'item.yaml' }
        it { subject.instance_variable_get(:@yaml).should ==
                              {'item1' => {'title' => 'book1'}} }
      end
    end
  end

  describe "#data" do
    subject { Yampla::Build.new(@yml).data }
    it { should be_instance_of(Array) }
    it { should have(2).items }
    its(:first) { should be_instance_of(Hashie::Mash) }
    its('first.title') { should eq 'book1' }
    its('first.price') { should be 100 }
    its('last.title') { should eq 'book2' }
    its('last.price') { should be 200 }
  end

  describe "#run" do
    context "for index" do
      context "w/o template" do
        subject { Yampla::Build.new(@yml).run(:index) }
        it "raise no template error" do
          expect { should }.to raise_error(Yampla::Build::TemplateError)
        end
      end
      context "w/ simple template" do
        subject { Yampla::Build.new(@yml).run(:index, template:~<<-EOS) }
          items size: {{ items.size }}
          EOS
        it { should eq "items size: 2\n" }
      end
      context "w/ simple template using alter name for items" do
        subject { Yampla::Build.new(@yml).run(:index, template:~<<-EOS, name:'books') }
          items size: {{ books.size }}
          EOS
        it { should eq "items size: 2\n" }
      end
      context "w/ list template" do
        subject { Yampla::Build.new(@yml).run(:index, template:~<<-EOS) }
          {% for item in items %}
          {{ item.id }}:{{ item.title }}({{ item.price }})
          {% endfor %}
          EOS
        it { should eq ~<<-EOS }

          item1:book1(100)

          item2:book2(200)

          EOS
      end
    end
    context "for each item" do
      context "w/o template" do
        subject { Yampla::Build.new(@yml).run(:items) }
        it "raise no template error" do
          expect { should }.to raise_error(Yampla::Build::TemplateError)
        end
      end
      context "w/ simple template" do
        subject { Yampla::Build.new(@yml).run(:items, template:~<<-EOS) }
          id:{{ item.id }}/title:{{ item.title }}/price:{{ item.price }}
          EOS
        it { should == {'item1' => "id:item1/title:book1/price:100\n",
                        'item2' => "id:item2/title:book2/price:200\n"} }
      end
      context "w/ simple template using alter name for item" do
        subject { Yampla::Build.new(@yml).run(:items, template:~<<-EOS, name:'book') }
          id:{{ book.id }}/title:{{ book.title }}/price:{{ book.price }}
          EOS
        it { should == {'item1' => "id:item1/title:book1/price:100\n",
                        'item2' => "id:item2/title:book2/price:200\n"} }
      end
    end
  end

  describe "#set_template" do
    context "with string template" do
      context "for index" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:index, ~<<-EOS)
            items size: {{ items.size }}
            EOS
        end
        subject { @ya.run(:index) }
        it { should eq "items size: 2\n" }
      end
      context "for items" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:items, ~<<-EOS)
          id:{{ item.id }}/title:{{ item.title }}/price:{{ item.price }}
          EOS
        end
        subject { @ya.run(:items) }
        it { should == {'item1' => "id:item1/title:book1/price:100\n",
                        'item2' => "id:item2/title:book2/price:200\n"} }
      end
    end
    context "with file template" do
      include FakeFS::SpecHelpers
      before do
        FakeFS.activate!
        File.open('index_template', 'w') { |f| f.puts ~<<-EOS }
          items size: {{ items.size }}
          EOS
        File.open('item_template', 'w') { |f| f.puts ~<<-EOS }
          id:{{ item.id }}/title:{{ item.title }}/price:{{ item.price }}
          EOS
      end
      context "for index" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:index, 'index_template')
        end
        subject { @ya.run(:index) }
        it { should eq "items size: 2\n" }
      end
      context "for items" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:items, 'item_template')
        end
        subject { @ya.run(:items) }
        it { should == {'item1' => "id:item1/title:book1/price:100\n",
                        'item2' => "id:item2/title:book2/price:200\n"} }
      end
      after { FakeFS.deactivate! }
    end
  end

  describe "#save" do
    include FakeFS::SpecHelpers
    before(:all) { FakeFS.activate! }
    context "for index" do
      context "w/o extension" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:index, ~<<-EOS)
            items size: {{ items.size }}
            EOS
          @ya.save(:index)
        end
        it "save a file" do
          File.open('out/index').read.should eq "items size: 2\n"
        end
      end
      context "w/ extension" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:index, ~<<-EOS)
            items size: {{ items.size }}
            EOS
          @ya.save(:index, ext:'txt')
        end
        it "save a file" do
          File.open('out/index.txt').read.should eq "items size: 2\n"
        end
      end
      context "specify file destination" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:index, ~<<-EOS)
            items size: {{ items.size }}
            EOS
          @ya.save(:index, dir:'result')
        end
        it "save a file" do
          File.open('result/index').read.should eq "items size: 2\n"
        end
      end
    end

    context "for items" do
      context "w/o extension" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:items, ~<<-EOS)
          id:{{ item.id }}/title:{{ item.title }}/price:{{ item.price }}
          EOS
          @ya.save(:items)
        end
        it "save a files" do
          File.open('out/item1').read.should eq "id:item1/title:book1/price:100\n"
          File.open('out/item2').read.should eq "id:item2/title:book2/price:200\n"
        end
      end
      context "w extension" do
        before do
          @ya = Yampla::Build.new(@yml)
          @ya.set_template(:items, ~<<-EOS)
          id:{{ item.id }}/title:{{ item.title }}/price:{{ item.price }}
          EOS
          @ya.save(:items, ext:'txt')
        end
        it "save a files" do
          File.open('out/item1.txt').read.should eq "id:item1/title:book1/price:100\n"
          File.open('out/item2.txt').read.should eq "id:item2/title:book2/price:200\n"
        end
      end
    end
    after(:all) { FakeFS.deactivate! }
  end
end
