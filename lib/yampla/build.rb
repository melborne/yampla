require "yaml"
require "hashie"
require "liquid"

class Yampla::Build
  attr_reader :data
  def initialize(yaml)
    @template = {}
    @yaml = yaml_parse(yaml)
    @data = yaml2object(@yaml)
  end

  def set_template(type, template)
    unless [:index, :items].include?(type.intern)
      raise ArgumentError, "First argument must :index or :items"
   end 
    @template[type] = parse_template(template)
  end

  def run(type, opt={})
    opt = {template:@template[type], name:nil}.merge(opt)
    case type
    when :index
      build_index(opt[:template], opt[:name])
    when :items
      build_items(opt[:template], opt[:name])
    else
      raise ArgumentError, "First argument must be :index or :items."
    end
  end

  def build_index(template, name=nil)
    Liquid::Template.parse(template).render("#{name || 'items'}" => @data)
  end

  def build_items(template, name=nil)
    @data.each_with_object({}) do |item, h|
      h[item.id] = Liquid::Template.parse(template).render("#{name || 'item'}" => item)
    end
  end

  def save(type, opt={})
    opt = {ext:nil, name:nil}.merge(opt)
    content = run(type, name:opt[:name])
    ext = ".#{opt[:ext]}" if opt[:ext]
    case type
    when :index
      File.open("index#{ext}", 'w') { |f| f.puts content }
    when :items
      content.each { |id, data| File.open("#{id}#{ext}", 'w') { |f| f.puts data } }
    end
  end

  private
  def yaml_parse(yaml)
    path?(yaml) ? YAML.load_file(yaml) : YAML.load(yaml)
  end

  def path?(str)
    str.match(/\w+\.(yaml|yml)$/)
  end

  def yaml2object(yaml)
    yaml.map { |id, data| Hashie::Mash.new( data.dup.update(id: id) ) }
  end

  def parse_template(template)
    File.read(template)
  rescue Errno::ENOENT
    return template if template.match(/.+?\.[^.]*$/)
  end
end
