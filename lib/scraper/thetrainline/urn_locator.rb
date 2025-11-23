# frozen_string_literal: true

require "httparty"
require "uri"

module Scraper
  module Thetrainline
    class UrnLocator
      # Trainline API endpoint for location search
      API_URL = "https://www.thetrainline.com/api/locations-search/v2/search"

      class << self
        def find_urn(search_term, logger, locale: "en-us")
          data = request_locations(search_term, logger, locale)
          return nil unless data && data["searchLocations"].is_a?(Array)
          choose_best_match(search_term, data["searchLocations"])
        end

        private

        def request_locations(search_term, logger, locale)
          HTTParty.get(
            API_URL,
            query: { locale: locale, searchTerm: search_term },
            timeout: 10
          )
        rescue StandardError => e
          logger.error "[UrnLocator] Failed to fetch locations: #{e.message}"
          nil
        end

        def choose_best_match(term, locations)
          normalized = term.downcase.strip
          
          exact = locations.find { |loc| loc["name"].downcase.strip == normalized }
          return extract_location_code(exact) if exact

          prefix = locations.find { |loc| loc["name"].downcase.strip.start_with?(normalized) }
          return extract_location_code(prefix) if prefix

          substring = locations.find { |loc| loc["name"].downcase.include?(normalized) }
          return extract_location_code(substring) if substring

          translated_name = locations.find { |loc| loc["translatedName"] ? loc["translatedName"].downcase.include?(normalized) : false }
          return extract_location_code(translated_name) if translated_name

          extract_location_code(locations.first) 
        end

        def extract_location_code(location)
          return nil unless location
          location["code"]
        end
      end
    end
  end
end
