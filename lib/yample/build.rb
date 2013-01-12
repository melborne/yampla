require "yaml"
require "hashie"

class Yample::Build
  attr_reader :yaml, :data
  def initialize(yaml)
    @yaml = yaml_parse(yaml)
    @data = yaml2object(@yaml)
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