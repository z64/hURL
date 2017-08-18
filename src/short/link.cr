require "http/client"
require "openssl/ssl/context"

module Short
  # For performing requests with TLS
  SSL_CONTEXT = OpenSSL::SSL::Context::Client.new

  # Maximum TTL on created `Link` objects
  # TODO: Make this configurable.
  MAX_TTL = 30.days.to_i

  # Minimum TTL on created `Link` objects
  # TODO: Make this configurable.
  MIN_TTL = 60

  # Converter for parsing JSON URL values into a `URI`
  # for performing validation
  module URIConverter
    def self.from_json(parser)
      URI.parse parser.read_string
    end

    def self.to_json(value, builder)
      builder.scalar(value.to_s)
    end
  end

  # A redirectable link that is validated against certain criteria,
  # and an expiry TTL (the TTL must be implemented by a `Cache`)
  class Link
    JSON.mapping({
      target:     {type: URI, converter: URIConverter},
      ttl:        {type: Int64, default: 5.minutes.to_i},
      code:       String?,
      created_at: Time?,
      uses:       {type: Int64, default: 0_i64},
    }, strict: true)

    def initialize(io : IO)
      initialize(JSON::PullParser.new(io))
      @created_at = Time.now
      validate!
    end

    # Increase the amount of times this `Link` has been used.
    # Mostly only useful for use with the `Memory` cache
    def use
      @uses += 1
    end

    # Validates this `Link` instance
    # Links must:
    #   - Be of HTTPS scheme
    #   - Be within MAX_TTL and MIN_TTL
    #   - The target URI must respond to a HEAD request with a `200 OK` status code
    def validate!
      raise InvalidURI.new("Only HTTPS schemes are accepted.") unless target.scheme == "https"
      raise InvalidTTL.new("TTL greater than MAX_TTL: #{MAX_TTL}") if ttl > MAX_TTL
      raise InvalidTTL.new("TTL less than MIN_TTL: #{MIN_TTL}") if ttl < MIN_TTL
      raise InvalidURI.new("Host not found at: #{target}") unless HTTP::Client.head(target, tls: SSL_CONTEXT).status_code == 200
    end
  end
end
