module Short
  # Cache interface, describing what a Cache must implement
  # to behave correctly with the rest of the application.
  abstract class Cache
    # Stores a Link object
    abstract def store(link : Link)

    # Retrieves a Link object by code
    abstract def resolve(code : String)
  end

  # A basic, in-memory implementation of `Cache`.
  # Mostly useful for debugging purposes, as it is
  # not persistant.
  class Memory < Cache
    # The cached `Link` objects.
    getter links = {} of String => Link

    # Stores a Link object
    def store(link : Link)
      code = (links.size + 1).to_s(62)

      link.code = code
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

    # Retrieves a Link object by code
    def resolve(code : String)
      links[code]
    end
  end
end
