# frozen_string_literal: true

require "date"

module DexcomShareApi
  class Glucose
    # {
    #   "WT"=>"Date(1709620791000)",
    #   "ST"=>"Date(1709620791000)",
    #   "DT"=>"Date(1709620791000-0500)",
    #   "Value"=>164,
    #   "Trend"=>"Flat",
    # }
    def initialize(raw_glucose_data)
      @raw_glucose_data = raw_glucose_data
    end

    def to_h
      {
        trend:,
        trend_arrow:,
        timestamp:,
        mmol:,
        mgdl:,
      }
    end

    def inspect
      out = "#<#{self.class}:#{object_id}"
      to_h.each do |key, value|
        out << " @#{key}=#{value}"
      end
      out << ">"
      out
    end

    def trend
      @raw_glucose_data["Trend"].split(/(?=[A-Z])/).join("-").downcase
    end

    def trend_arrow
      case trend
      when "double-up"
        "↑↑"
      when "single-up"
        "↑"
      when "forty-five-up"
        "↗"
      when "flat"
        "→"
      when "forty-five-down"
        "↘"
      when "single-down"
        "↓"
      when "double-down"
        "↓↓"
      else
        raise StandardError, "Unhandled trend `#{trend}`. This is a bug!"
      end
    end

    # This is parsing out an epoch time from "Date(1709620791000)". It's messy.
    def timestamp
      raw_timestamp = @raw_glucose_data["ST"].match(/\d+/)[0]
      DateTime.strptime(raw_timestamp, '%Q').iso8601
    end

    def mmol
      mgdl_to_mmol(mgdl)
    end

    def mgdl
      @raw_glucose_data["Value"].to_f
    end

    private

    # http://www.bcchildrens.ca/endocrinology-diabetes-site/documents/glucoseunits.pdf
    # [BG (mmol/L) * 18] = BG (mg/dL)
    #
    # Return the normalized mmol/L
    def mgdl_to_mmol(mgdl)
      (mgdl.to_f / 18).round(2)
    end
  end
end
