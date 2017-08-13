module Short
  abstract class Cache
    abstract def store(link : Link)
    abstract def fetch(code : String)
  end

  class Memory < Cache
    getter links = {} of String => Link

    def store(link : Link)
      code = (links.size + 1).to_s(62)
      link.code = code
      @links[code] = link
    end

    def fetch(code : String)
      links[code]
    end
  end
end
