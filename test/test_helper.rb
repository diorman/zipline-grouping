# frozen_string_literal: true

require "simplecov"
require "simplecov-console"

SimpleCov::Formatter::Console.show_covered = true

SimpleCov.start do
  formatter SimpleCov::Formatter::Console
end

require "minitest/autorun"

require_relative "../lib/environment"
