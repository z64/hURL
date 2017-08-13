require "json"
require "raze"
require "./short/link"
require "./short/middleware"
require "./short/cache"

module Short
  @@cache = Memory.new

  get "/link/:code" do |ctx|
    code = ctx.params["code"]

    if link = @@cache.fetch(code.as(String))
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

  post "/create", ContentType.new do |ctx|
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
