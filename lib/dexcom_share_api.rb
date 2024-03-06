# frozen_string_literal: true

require "dexcom_share_api/version"
require "dexcom_share_api/client"

module DexcomShareApi
  def self.create_client(...)
    DexcomShareApi::Client.new(...)
  end
end
