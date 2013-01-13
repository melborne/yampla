
module Yampla
  %w(version build).each { |lib| require_relative "yampla/#{lib}" }
end
