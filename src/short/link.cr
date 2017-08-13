require "http/client"
require "openssl/ssl/context"

module Short
  SSL_CONTEXT = OpenSSL::SSL::Context::Client.new

  MAX_TTL = 30.days.to_i
  MIN_TTL = 60

  module URIConverter
    def self.from_json(parser)
      URI.parse parser.read_string
    end

    def self.to_json(value, builder)
      builder.scalar(value.to_s)
    end
  end

  class InvalidURI < Exception
  end

  class InvalidTTL < Exception
  end

  class Link
    JSON.mapping(
      target: {type: URI, converter: URIConverter},
      ttl: {type: Int64, default: 5.minutes.to_i},
      code: String?,
      created_at: Time?,
      uses: {type: Int64, default: 0_i64}
    )

    def initialize(io : IO)
      initialize(JSON::PullParser.new(io))
      @created_at = Time.now
      validate!
    end

    def use
      @uses += 1
    end

    def validate!
      raise InvalidURI.new("Only HTTPS schemes are accepted.") unless target.scheme == "https"
      raise InvalidTTL.new("TTL greater than MAX_TTL: #{MAX_TTL}") if ttl > MAX_TTL
      raise InvalidTTL.new("TTL greater than MIN_TTL: #{MIN_TTL}") if ttl < MIN_TTL
      raise InvalidURI.new("Host not found at: #{target}") unless HTTP::Client.head(target, tls: SSL_CONTEXT).status_code == 200
    end
  end
end
