require "delegate"
require "faraday"
require "json"

module Countries
  class CLI
    def initialize(api = API.new)
      @api = api
    end

    def summary(options = {})
      SummaryCommand.new(@api, options)
    end

    class SummaryCommand
      def initialize(api, options)
        @api = api
        @sort_by = options.fetch(:sort_by, :name)
        @filter_by = options.fetch(:filter_by, {})
      end

      def entries
        countries.sort_by(&@sort_by).map { |c| CountryEntry.new(c) }
      end

      def entry_with_max_area
        CountryEntry.new(countries.max { |x, y| x.area <=> y.area })
      end

      def entry_with_min_area
        CountryEntry.new(countries.min { |x, y| x.area <=> y.area })
      end

      def population_average
        arr = countries.map(&:population).compact
        return "0.0M" if arr.empty?
        format("%.1fM", (arr.sum / arr.size) / 1_000_000.0)
      end

      private def countries
        # Filter out countries with null areas just for the example 😎
        @countries ||= find_countries.reject { |c| c.area == nil }
      end

      private def find_countries
        if @api.respond_to?(:"find_by_#{@filter_by[:attr]}")
          @api.send(:"find_by_#{@filter_by[:attr]}", @filter_by[:value])
        else
          @api.find_all
        end
      end

      class CountryEntry < SimpleDelegator
        def area
          to_mi2(super).to_i
        end

        def population
          format("%.1fM", super / 1_000_000.0)
        end

        private

        def to_mi2(km2)
          km2 / 2.59
        end
      end
    end
  end

  class API
    BASE_URL = "https://restcountries.com/v3.1"

    def initialize(http_client = Faraday)
      @http_client = http_client
    end

    def find_all
      get_response("/all").map { Country.new(_1) }
    end

    %i[name region subregion lang].each do |filter|
      define_method(:"find_by_#{filter}") do |value|
        get_response("/#{filter}/#{value}").map { Country.new(_1) }
      end
    end

    private

    def get_response(path)
      response = @http_client.get(build_url(path))

      if response.success?
        JSON.parse(response.body)
      else
        raise Error.new(response)
      end
    end

    def build_url(path)
      url = URI.parse(BASE_URL)
      url.path += path
      url
    end

    class Error < StandardError
      attr_reader :response

      def initialize(response)
        super(response.reason_phrase)
        @response = response
      end
    end

    class Country
      attr_reader :name,
                  :region,
                  :area,
                  :population

      def initialize(attributes)
        @name = attributes["name"]&.[]("common")
        @region = attributes["region"]
        @area = attributes["area"]
        @population = attributes["population"]
      end
    end
  end
end
