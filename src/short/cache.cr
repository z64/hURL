module Short
  # Cache interface, describing what a Cache must implement
  # to behave correctly with the rest of the application.
  abstract class Cache
    # Stores a Link object
    abstract def store(link : Link)

    # Retrieves a Link object by code
    abstract def resolve(code : String)
  end

  # Exception to raise when an invalid code is given
  class InvalidCode < Exception
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
      (links.size + 1).to_s(62)
    end

    # Retrieves a Link object by code
    def resolve(code : String)
      links[code]?
    end
  end
end
