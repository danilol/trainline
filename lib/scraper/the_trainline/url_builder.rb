# frozen_string_literal: true
require './lib/scraper/the_trainline/urn_locator.rb'

module Scraper
  class TheTrainline
    class UrlBuilder
      BASE_URL = "https://www.thetrainline.com"

      def initialize(origin, destination, date)
        @origin = origin
        @destination = destination
        @date = date
      end

      def build
        @origin_encoded_urn = encode_param(find_urn_locator(@origin))
        @destination_encoded_urn = encode_param(find_urn_locator(@destination))
        "#{BASE_URL}/book/results?origin=#{@origin_encoded_urn}&destination=#{@destination_encoded_urn}&outwardDate=#{encode_param(@date)}"
      end

      private

      def encode_param(param)
        URI.encode_www_form_component(param.to_s)
      end

      def find_urn_locator(location)
        Scraper::TheTrainline::UrnLocator.find_urn(location)
      end
    end
  end
end