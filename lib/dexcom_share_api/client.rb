# frozen_string_literal: true

require "dexcom_share_api/http_api"
require "dexcom_share_api/glucose"

module DexcomShareApi
  class Client
    attr_reader(:dexcom_api)

    def initialize(username:, password:, server:)
      @dexcom_api ||= HttpApi.new(username:, password:, server:)
    end

    def estimated_glucose(last: 10)
      result = dexcom_api.fetch_estimated_glucose!(last:)

      result
        .map { |entry| Glucose.new(entry) }
        .reverse
    end

    def last_estimated_glucose
      result = dexcom_api.fetch_estimated_glucose!(last: 1)

      Glucose.new(result[0])
    end
  end
end
