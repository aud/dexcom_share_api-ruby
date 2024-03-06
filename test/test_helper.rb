# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "dexcom_share_api"

require "minitest/autorun"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
  # Helpful for dumping requests:
  #
  # config.before_http_request do |req|
  #   puts req.uri
  #   puts req.body
  # end
end
