require "yample"
require "rspec"
require "fakefs/spec_helpers"

class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end
end
