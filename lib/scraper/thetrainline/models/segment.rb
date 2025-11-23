# frozen_string_literal: true

module Scraper
  module Thetrainline
    module Models
      class Segment
        attr_reader :departure_station, :departure_at, :arrival_station, :arrival_at, :service_agencies, :duration_in_minutes, :changeovers, :products, :fares

        def initialize(departure_station:, departure_at:, arrival_station:, arrival_at:, service_agencies: [], duration_in_minutes: 0, changeovers: 0, products: [], fares: [])
          @departure_station = departure_station
          @departure_at = departure_at
          @arrival_station = arrival_station
          @arrival_at = arrival_at
          @service_agencies = service_agencies
          @duration_in_minutes = duration_in_minutes
          @changeovers = changeovers
          @products = products
          @fares = fares
        end
      end
    end
  end
end