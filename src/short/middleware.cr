module Short
  class ContentType < Raze::Handler
    def call(ctx, done)
      ctx.response.headers["Content-Type"] = "application/json"
      done.call
    end
  end
end
