# frozen_string_literal: true

class KeyBuilder
  FIELD_MAPPINGS = { email: ["Email", "Email1", "Email2"], phone: ["Phone", "Phone1", "Phone2"] }.freeze

  def initialize(field_groups)
    @field_groups = field_groups
  end

  def build(row)
    @field_groups.flat_map { |field_group| keys_for(field_group, row) }.uniq
  end

  private

  def keys_for(field_group, row)
    FIELD_MAPPINGS[field_group].filter_map do |field|
      value = normalize(field_group, row[field])
      "#{field_group}:#{value}" unless value.nil? || value.empty?
    end
  end

  def normalize(field_group, value)
    case field_group
    when :email then value&.strip&.downcase
    # remove everything that's not a number
    when :phone then value&.gsub(/\D/, "")
    end
  end
end
