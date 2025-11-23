# frozen_string_literal: true

module Scraper
  module Thetrainline
    module Models
      class Fare
        attr_reader :name, :price_in_cents, :currency

        def initialize(name:, price_in_cents:, currency:)
          @name = name
          @price_in_cents = price_in_cents
          @currency = currency
        end
      end
    end
  end
end