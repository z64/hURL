require "json"
require "raze"
require "./short/link"
require "./short/middleware"
require "./short/cache"

module Short
  {% if flag?(:memory_cache) %}
    @@cache = Memory.new
  {% else %}
    {{raise "Only Memory cache currently supported. Compile with flag memory-cache."}}
  {% end %}

  # Resolves a link code and executes a redirect.
  # If the requester will `Accept` `application/json`,
  # the `Link` object as JSON is returned instead and no
  # redirect is performed.
  get "/link/:code", Logger.new do |ctx|
    code = ctx.params["code"]

    if link = @@cache.resolve(code.as(String))
      if ctx.request.headers["Accept"] == "application/json"
        link.to_json
      else
        link.use
        ctx.redirect link.target.to_s
      end
    else
      ctx.halt "Not Found", 404
    end
  end

  # Creates a new Link.
  # This route requires a User-Agent that passes the `RequireUserAgent` middleware.
  # The JSON at minimum must contain a string `target` key, which must
  # have an HTTPS scheme and respond to a HEAD request with a 200 response.
  # Returns the created `Link` object.
  post "/create", Logger.new, RequireUserAgent.new, JSONContentType.new do |ctx|
    begin
      link = Link.new(ctx.request.body.as(IO))
      @@cache.store(link)
      link.to_json
    rescue ex : JSON::ParseException
      ctx.halt_plain "Invalid JSON Body (#{ex.class}): #{ex.message}", 400
    rescue ex : InvalidURI
      ctx.halt_plain "Invalid URI: #{ex.message}", 400
    rescue ex : InvalidTTL
      ctx.halt_plain "Invalid TTL: #{ex.message}", 400
    end
  end
end

Raze.run
