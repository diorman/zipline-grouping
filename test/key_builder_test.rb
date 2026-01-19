# frozen_string_literal: true

require_relative "test_helper"

describe KeyBuilder do
  describe "#build" do
    it "extracts unique email and phone keys from row" do
      row = {
        "Name" => "John",
        "Email" => "j1@test.com",
        "Email1" => "j1@test.com",
        "Email2" => "j3@test.com",
        "Phone" => "123",
        "Phone1" => "321",
        "Phone2" => "321",
      }
      keys = KeyBuilder.new([:email, :phone]).build(row)

      expect(keys).must_equal(["email:j1@test.com", "email:j3@test.com", "phone:123", "phone:321"])
    end

    it "filters out blank values" do
      row = { "Email1" => nil, "Email2" => "john@test.com", "Phone" => "" }
      keys = KeyBuilder.new([:email, :phone]).build(row)

      expect(keys).must_equal(["email:john@test.com"])
    end

    it "returns empty array when no fields are present" do
      row = { "Name" => "John" }
      keys = KeyBuilder.new([:email, :phone]).build(row)

      expect(keys).must_be_empty
    end

    it "normalizes email values" do
      row = { "Email" => "   John@Test.COM  " }
      keys = KeyBuilder.new([:email]).build(row)

      expect(keys).must_equal(["email:john@test.com"])
    end

    it "normalizes phone values" do
      row = {
        "Phone" => "(555) 123-4567",
        "Phone1" => "555.123.4567",
        "Phone2" => "555-123-4567",
      }
      keys = KeyBuilder.new([:phone]).build(row)

      expect(keys).must_equal(["phone:5551234567"])
    end
  end
end
