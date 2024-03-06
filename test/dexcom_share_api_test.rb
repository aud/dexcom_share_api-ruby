# frozen_string_literal: true

require "test_helper"

class DexcomShareApiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DexcomShareApi::VERSION
  end

  def test_create_client_passes
    client = DexcomShareApi.create_client(
      username: "username",
      password: "hunter2",
      server: "us",
    )

    assert_instance_of(DexcomShareApi::Client, client)
  end

  def test_server_validation_raises
    assert_raises(DexcomShareApi::HttpApi::InvalidServerError) do
      DexcomShareApi::Client.new(
        username: "username",
        password: "hunter2",
        server: "invalid",
      )
    end
  end

  def test_server_validation_passes
    begin
      DexcomShareApi::Client.new(
        username: "username",
        password: "hunter2",
        server: "us",
      )

      DexcomShareApi::Client.new(
        username: "username",
        password: "hunter2",
        server: "outside-us",
      )
    rescue => err
      flunk("Expected pass, got #{err.inspect}")
    end
  end

  def test_estimated_glucose_passes
    client = DexcomShareApi::Client.new(
      username: "username",
      password: "hunter2",
      server: "outside-us",
    )

    VCR.use_cassette("dexcom_estimated_glucose") do
      glucose = client.estimated_glucose

      actual = glucose.first

      assert_equal(9.78, actual.mmol)
      assert_equal(176.0, actual.mgdl)
      assert_equal("forty-five-down", actual.trend)
      assert_equal("↘", actual.trend_arrow)
      assert_equal("2024-03-06T02:14:53+00:00", actual.timestamp)
    end
  end

  def test_last_estimated_glucose_passes
    client = DexcomShareApi::Client.new(
      username: "username",
      password: "hunter2",
      server: "outside-us",
    )

    VCR.use_cassette("dexcom_estimated_glucose") do
      actual = client.last_estimated_glucose

      assert_equal(10.72, actual.mmol)
      assert_equal(193.0, actual.mgdl)
      assert_equal("flat", actual.trend)
      assert_equal("2024-03-06T02:59:53+00:00", actual.timestamp)

      expected = {
        trend: "flat",
        trend_arrow: "→",
        timestamp: "2024-03-06T02:59:53+00:00",
        mmol: 10.72,
        mgdl: 193.0,
      }

      assert_equal(expected, actual.to_h)
    end
  end

  def test_last_estimated_glucose_raises
    client = DexcomShareApi::Client.new(
      username: "username",
      password: "hunter2",
      server: "outside-us",
    )

    VCR.use_cassette("dexcom_estimated_glucose_error") do
      assert_raises(DexcomShareApi::HttpApi::ApiError) do
        client.last_estimated_glucose
      end
    end
  end
end
