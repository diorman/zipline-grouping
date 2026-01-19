# frozen_string_literal: true

module CLI
  MATCHING_TYPES = {
    same_email: [:email],
    same_phone: [:phone],
    same_email_or_phone: [:email, :phone],
    same_phone_or_email: [:email, :phone],
  }.freeze

  USAGE = "Usage: csv_cli <file> <matching_type>"

  class << self
    def run(argv)
      file = argv[0]
      matching_type = argv[1]&.to_sym

      abort_with(USAGE) if file.nil? || matching_type.nil?
      abort_with("File not found: #{file}") unless File.exist?(file)
      abort_with(invalid_type_message) unless MATCHING_TYPES.key?(matching_type)

      print_csv(file, MATCHING_TYPES[matching_type])
    end

    private

    def print_csv(file, fields)
      headers_printed = false

      CSVProcessor.process(file, fields) do |row|
        unless headers_printed
          puts row.headers.to_csv
          headers_printed = true
        end

        puts row.to_csv
      end
    end

    def invalid_type_message
      "Invalid matching type. Supported types: #{MATCHING_TYPES.keys.join(", ")}"
    end

    def abort_with(message)
      warn(message)
      exit(1)
    end
  end
end
