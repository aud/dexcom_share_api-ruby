# frozen_string_literal: true

require "net/http"
require "json"
require "dexcom_share_api/glucose"

module DexcomShareApi
  class HttpApi
    InvalidServerError = Class.new(ArgumentError)
    ApiError = Class.new(StandardError)

    # This server needs to be either "us" or "eu. If you're in the US, the server
    # should be "us". Any other country outside of the US (eg. Canada) is
    # classified as "eu" by Dexcom.
    VALID_SERVERS = ["us", "outside-us"]

    # This seems to be a blessed ID the Dexcom Share app uses. This is in no way
    # special to this library, is it used in several (nightscout, dexcomedy,
    # etc).
    APPLICATION_ID = "d8665ade-9673-4e27-9ff6-92db4ce13d13"

    def initialize(username:, password:, server:)
      validate_server!(server)

      @username = username
      @password = password
      @server = server
    end

    def fetch_estimated_glucose!(last:, minutes: 24 * 60)
      session_id = fetch_session_id!

      uri = URI::HTTPS.build(
        host: base_host,
        path: "/ShareWebServices/Services/Publisher/ReadPublisherLatestGlucoseValues",
      )

      data = {
        maxCount: last,
        sessionId: session_id,
        minutes: minutes,
      }

      dexcom_request!(uri, data)
    end

    def fetch_session_id!
      account_id = fetch_account_id!

      uri = URI::HTTPS.build(
        host: base_host,
        path: "/ShareWebServices/Services/General/LoginPublisherAccountById",
      )

      data = {
        applicationId: APPLICATION_ID,
        accountId: account_id,
        password: @password,
      }

      dexcom_request!(uri, data)
    end

    def fetch_account_id!
      uri = URI::HTTPS.build(
        host: base_host,
        path: "/ShareWebServices/Services/General/AuthenticatePublisherAccount",
      )

      data = {
        applicationId: APPLICATION_ID,
        accountName: @username,
        password: @password,
      }

      dexcom_request!(uri, data)
    end

    private

    def dexcom_request!(uri, data)
      request = Net::HTTP::Post.new(
        uri.request_uri,
        {
          "Content-Type" => "application/json",
        }
      )

      request.body = data.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      body = JSON.parse(response.body)

      if response.code.to_i != 200
        err_msg = <<~MSG
          Error! Dexcom request to "#{uri}" failed.

          Response code: #{response.code}
          Raw request body:
            `Code=#{body["Code"]}`
            `Message=#{body["Message"]}`
        MSG

        raise(ApiError, err_msg)
      end

      body
    rescue ApiError => err
      raise
    rescue => err
      raise(ApiError, err)
    end

    def base_host
      case @server
      when "us"
        "share2.dexcom.com"
      when "outside-us"
        "shareous1.dexcom.com"
      end
    end

    def validate_server!(server)
      return if VALID_SERVERS.include?(server)

      err_msg = <<~MSG
        Server must either be `us` or `outside-us`.

        If you're in the US, the server should be "us". Any other country
        outside of the US (eg. Canada) should be "outside-us".
      MSG

      raise(InvalidServerError, err_msg)
    end
  end
end
