# frozen_string_literal: true

require_relative "test_helper"
require "tempfile"

describe CSVProcessor do
  describe ".process" do
    it "prepends ID column to CSV output" do
      rows = [CSV::Row.new(["Name", "Email"], ["John", "john@test.com"])]

      CSVProcessor.process_rows(rows, [:email]) do |row|
        expect(row.headers).must_equal(["ID", "Name", "Email"])
      end
    end

    it "assigns same ID to matching rows" do
      rows = [
        CSV::Row.new(["Name", "Email"], ["John", "john@test.com"]),
        CSV::Row.new(["Name", "Email"], ["Jane", "john@test.com"]),
      ]

      results = []
      CSVProcessor.process_rows(rows, [:email]) { |row| results << row }
      expect(results[0]["ID"]).must_equal(results[1]["ID"])
    end

    it "assigns different IDs to unmatching" do
      rows = [
        CSV::Row.new(["Name", "Email"], ["John", "john@test.com"]),
        CSV::Row.new(["Name", "Email"], ["Jane", "jane@test.com"]),
      ]

      results = []
      CSVProcessor.process_rows(rows, [:email]) { |row| results << row }
      expect(results[0]["ID"]).wont_equal(results[1]["ID"])
    end

    it "handles indirect matching" do
      rows = [
        CSV::Row.new(["Name", "Phone1", "Phone2"], ["John", "111", "222"]),
        CSV::Row.new(["Name", "Phone1", "Phone2"], ["John", "333", "444"]),
        CSV::Row.new(["Name", "Phone1", "Phone2"], ["John", "222", "333"]),
      ]

      results = []
      CSVProcessor.process_rows(rows, [:phone]) { |row| results << row }

      expect(results[0]["ID"]).must_equal(results[1]["ID"])
      expect(results[0]["ID"]).must_equal(results[2]["ID"])
    end

    it "preserves original data in output" do
      rows = [
        CSV::Row.new(["FirstName", "LastName", "Email", "Zip"], ["John", "Doe", "john@test.com", "111"]),
        CSV::Row.new(["FirstName", "LastName", "Email", "Zip"], ["Jane", "Smith", "jane@test.com", "222"]),
      ]

      results = []
      CSVProcessor.process_rows(rows, [:email]) { |row| results << row }

      expect(results[0].values_at("FirstName", "LastName", "Email", "Zip"))
        .must_equal(["John", "Doe", "john@test.com", "111"])

      expect(results[1].values_at("FirstName", "LastName", "Email", "Zip"))
        .must_equal(["Jane", "Smith", "jane@test.com", "222"])
    end

    it "handles empty CSV file" do
      results = []
      CSVProcessor.process_rows([], [:email]) { |row| results << row }
      expect(results).must_be_empty
    end

    it "handles rows with missing identifiers" do
      rows = [
        CSV::Row.new(["Name", "Email"], ["John", "john@test.com"]),
        CSV::Row.new(["Name", "Email"], ["Jane", ""]),
        CSV::Row.new(["Name", "Email"], ["Jack", ""]),
      ]

      results = []
      CSVProcessor.process_rows(rows, [:email]) { |row| results << row }

      # all resulting rows have different IDs
      expect(results.map { |row| row["ID"] }.uniq.size).must_equal(3)
    end
  end
end
