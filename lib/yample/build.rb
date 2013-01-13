require "yaml"
require "hashie"
require "liquid"

class Yample::Build
  attr_reader :data
  def initialize(yaml)
    @template = {}
    @yaml = yaml_parse(yaml)
    @data = yaml2object(@yaml)
  end

  def set_template(type, template)
    @template[type] = template
  end

  def run(target, template=@template[target], name=nil)
    case target
    when :index
      build_index(template, name)
    when :items
      build_items(template, name)
    else
      raise "First argument must be :index or :items."
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
end
