
module Yampla
  %w(version system_extension build).each { |lib| require_relative "yampla/#{lib}" }
end
