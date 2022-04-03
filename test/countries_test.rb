require "bundler/setup"
require "minitest/autorun"
require "minitest/pride"
require_relative "../lib/countries"

StubHttpClient = Faraday.new do |builder|
  builder.adapter :test do |stub|
    stub.get("https://restcountries.eu/rest/v2/all") do
      [
        200,
        { "Content-Type" => "application/json"},
        <<~EOS
          [
            {
              "name": "Norway",
              "region": "Europe",
              "population": 5223256,
              "area": 323802.0
            },
            {
              "name": "Sweden",
              "region": "Europe",
              "population": 9894888,
              "area": 450295.0
            },
            {
              "name": "Denmark",
              "region": "Europe",
              "population": 5717014,
              "area": 43094.0
            }
          ]
        EOS
      ]
    end

    stub.get("https://restcountries.eu/rest/v2/region/Americas") do
      [
        200,
        { "Content-Type" => "application/json"},
        <<~EOS
          [
            {
              "name": "Peru",
              "region": "Americas",
              "population": 31488700,
              "area": 1285216.0
            },
            {
              "name": "Colombia",
              "region": "Americas",
              "population": 48759958,
              "area": 1141748.0
            }
          ]
        EOS
      ]
    end
  end
end

module Countries
  class CLITest < Minitest::Test
    def setup
      @cli = CLI.new(API.new(StubHttpClient))
    end

    def test_summary
      summary = @cli.summary

      assert_equal "6.9M", summary.population_average

      entry_with_max_area = summary.entry_with_max_area
      refute_nil entry_with_max_area
      assert_equal "Sweden", entry_with_max_area.name

      entry_with_min_area = summary.entry_with_min_area
      refute_nil entry_with_min_area
      assert_equal "Denmark", entry_with_min_area.name
    end

    def test_summary_entries_sorted_by_name_as_default
      summary = @cli.summary

      entries = summary.entries

      assert_equal 3, entries.size
      assert_equal "Denmark", entries[0].name
      assert_equal "Norway", entries[1].name
      assert_equal "Sweden", entries[2].name
    end

    def test_summary_entries_sorted_by_area
      summary = @cli.summary(sort_by: :area)

      entries = summary.entries

      assert_equal 3, entries.size
      assert_equal "Denmark", entries[0].name
      assert_equal "Norway", entries[1].name
      assert_equal "Sweden", entries[2].name
    end

    def test_summary_entry_attributes
      entries = @cli.summary&.entries
      refute_nil entries

      entry = entries.find { |e| e.name == "Norway" }
      assert_equal 125020, entry.area
      assert_equal "5.2M", entry.population
      assert_equal "Europe", entry.region
    end

    def test_summary_by_region
      summary = @cli.summary(filter_by: { attr: "region", value: "Americas" })
      refute_nil summary

      entries = summary.entries
      assert_equal 2, entries.size
    end
  end

  class APITest < Minitest::Test
    def setup
      @api = API.new(StubHttpClient)
    end

    def test_find_all
      countries = @api.find_all
      refute_empty countries

      country = countries.find { |c| c.name == "Norway" }
      refute_nil country
      assert_equal "Europe", country.region
      assert_equal 323802.0, country.area
      assert_equal 5223256, country.population
    end

    def test_find_by_region
      countries = @api.find_by_region("Americas")
      refute_empty countries

      country = countries.find { |c| c.name == "Peru" }
      refute_nil country
    end
  end
end
