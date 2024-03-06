TLDR; This is a tiny gem to interact with the Dexcom Share API. The API is
(unfortunately) private, so _any_ implementation can't really have stability
guarantees. However, it hasn't changed for the past few years so it should be
fairly stable. Feel free to report any bugs and I'll fix them!

## Usage
```ruby
require "dexcom_share_api"

# Create a client with your username and password from Dexcom Share.
# If you get authentication issues, try to confirm your username/password by
# logging into Dexcom Share directly.
client = DexcomShareApi.create_client(
  username: "Dexcom share username",
  password: "Dexcom share password",
  # If your account is registered in the US, otherwise `outside-us`.
  server: "us",
)

# Defaults to outputting the last 10 entries
# Optionally can pass in the _last_ parameter.
# ```
#   client.estimated_glucose(last: 5)
# ```
glucose = client.estimated_glucose
glucose.each do |entry|
  puts entry.mmol # => 5.39
  puts entry.mgdl # => 151.0
  puts entry.trend # => "flat"
  # Timestamp is an iso8601
  puts entry.timestamp # => "2024-03-06T04:14:53+00:00"
end

# Alternatively, to grab the last entry:
glucose = client.last_estimated_glucose
puts glucose.to_h # => {:trend=>"flat", :timestamp=>"2024-03-06T04:14:53+00:00", :mmol=>8.39, :mgdl=>151.0}
```

## History
I originally made this library in
[JavaScript](https://github.com/aud/dexcom-share-api) many years ago to enable
some watch-face development. Recently I had a use-case where I wanted to store
a bunch of Dexcom data in a database for some offline analysis, and decided I'd
port it to Ruby to make that process more enjoyable.

## Development

To test:
* `bin/test`

To build:
* `gem build && gem install dexcom_share_api`
