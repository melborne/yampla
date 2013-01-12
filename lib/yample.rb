
module Yample
  %w(version build).each { |lib| require_relative "yample/#{lib}" }
end
