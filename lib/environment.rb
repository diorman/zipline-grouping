# frozen_string_literal: true

# Load all .rb files in the same directory as this file
Dir[File.join(__dir__, "*.rb")].sort.each do |file|
  require_relative file unless file == __FILE__
end
