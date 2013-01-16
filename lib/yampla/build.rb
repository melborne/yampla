require "yaml"
require "hashie"
require "liquid"

class Yampla::Build
  class TemplateError < StandardError; end
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
    raise TemplateError, 'Template for index not set.' unless template
    Liquid::Template.parse(template).render("#{name || 'items'}" => @data)
  end

  def build_items(template, name=nil)
    raise TemplateError, 'Template for items not set.' unless template
    @data.each_with_object({}) do |item, h|
      h[item.id] = Liquid::Template.parse(template).render("#{name || 'item'}" => item)
    end
  end

  def save(type, opt={})
    opt = {ext:@extname, name:nil, dir:'out'}.merge(opt)
    content = run(type, name:opt[:name])
    ext = ".#{opt[:ext]}" if opt[:ext]
    dir = opt[:dir]
    Dir.mkdir(dir) unless Dir.exists?(dir)
    case type
    when :index
      path = File.join(dir, "index#{ext}")
      File.open(path, 'w') { |f| f.puts content }
    when :items
      content.each do |id, data|
        path = File.join(dir, "#{id}#{ext}")
        File.open(path, 'w') { |f| f.puts data }
      end
    end
  end

  private
  def yaml_parse(yaml)
    yaml.match(/\w+\.(yaml|yml)$/) ? YAML.load_file(yaml) : YAML.load(yaml)
  end

  def yaml2object(yaml)
    yaml.map { |id, data| Hashie::Mash.new( data.dup.update(id: id) ) }
  end

  def parse_template(template)
    File.read(template).tap { @extname = File.extname(template)[1..-1] }
  rescue Errno::ENOENT
    #:FIXME: but impl!
    if template.match(/^\w{1,20}\.\w{1,8}$/) #match only filename but string
      raise Errno::ENOENT
    else
      template
    end
  end
end
