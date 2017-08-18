require "redis"

module Short
  # Cache interface, describing what a Cache must implement
  # to behave correctly with the rest of the application.
  abstract class Cache
    # Stores a Link object
    abstract def store(link : Link)

    # Retrieves a Link object by code
    abstract def resolve(code : String)
  end

  # Redis cache
  class Redis < Cache
    getter redis = ::Redis.new

    # Stores a Link object.
    # Raises an `InvalidCode` exception if the link already has a `code` present
    # and that `code` is already in-use.
    def store(link : Link)
      if code = link.code
        raise InvalidCode.new("Code cannot be empty") if code.empty?
        raise InvalidCode.new("Code already exists") if redis.exists("short:link:#{code}") == 1
      else
        link.code = next_code
      end

      code = link.code.not_nil!

      key = "short:link:#{code}"
      redis.set(key, link.to_json, link.ttl)
      redis.set("#{key}:uses", 0, link.ttl)
    end

    # Returns the next code in sequence
    # NOTE: This doesn't check to see if the last code was used, and will always increment
    #   the `Redis` index.
    private def next_code
      code = redis.incr("short:links").to_s(62)
      return next_code if redis.exists("short:link:#{code}") == 1
      code
    end

    # Retrieves a Link object by code.
    # In contrast with `Memory`, this will increment the amount of times
    # the link is used each time it is resolved, regardless if it is used for a redirect.
    def resolve(code : String)
      key = "short:link:#{code}"

      if json = redis.get(key)
        link = Link.from_json(json)
        link.ttl = redis.ttl(key)
        link.uses = redis.incr("#{key}:uses")

        link
      end
    end
  end

  # A basic, in-memory implementation of `Cache`.
  # Mostly useful for debugging purposes, as it is
  # not persistant.
  class Memory < Cache
    # The cached `Link` objects.
    getter links = {} of String => Link

    # Stores a Link object.
    # Raises an `InvalidCode` exception if the link already has a `code` present
    # and that `code` is already in-use
    def store(link : Link)
      if code = link.code
        raise InvalidCode.new("Code cannot be empty") if code.empty?
        raise InvalidCode.new("Code already exists") if links.has_key?(code)
      else
        link.code = next_code
      end

      code = link.code.not_nil!

      expire(link)

      @links[code] = link
    end

    # Sets up a fiber to expire this link after
    # the `Link`'s `#ttl`.
    private def expire(link)
      spawn do
        sleep link.ttl.seconds
        @links.delete(link.code)
      end
    end

    # Returns the next code based on the current links hash
    private def next_code
      code = (links.size + 1).to_s(62)
      return next_code if links.has_key?(code)
      code
    end

    # Retrieves a Link object by code
    def resolve(code : String)
      links[code]?
    end
  end
end
