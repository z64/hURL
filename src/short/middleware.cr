require "logger"

module Short
  LOGGER = ::Logger.new(STDOUT)
  LOGGER.level = ::Logger::DEBUG

  class Logger < Raze::Handler
    def call(ctx, done)
      request = ctx.request
      LOGGER.info "#{request.method} #{request.resource} [#{request.headers["User-Agent"]} #{request.host}]"
      done.call
    end
  end

  class JSONContentType < Raze::Handler
    def call(ctx, done)
      ctx.response.headers["Content-Type"] = "application/json"
      done.call
    end
  end
end
