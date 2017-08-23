require "logger"

module Hurl
  # Logger instance
  LOGGER = ::Logger.new(STDOUT)

  # Logger level
  # TODO: Make this configurable.
  LOGGER.level = ::Logger::DEBUG

  # Middleware for logging all incoming requests
  class Logger < Raze::Handler
    def call(ctx, done)
      request = ctx.request
      LOGGER.info "#{request.method} #{request.resource} [#{request.headers["User-Agent"]} #{request.host}]"
      done.call
    end
  end

  # Middleware for validating `User-Agent` header is present
  # Halts the context if it isn't
  class RequireUserAgent < Raze::Handler
    def call(ctx, done)
      user_agent = ctx.request.headers["User-Agent"]
      return ctx.halt_plain "You must supply a User-Agent.", 400 if user_agent.nil? || user_agent.empty?
      done.call
    end
  end

  # Middleware for setting the `Content-Type` header to `application/json`
  # in applicable routes
  class JSONContentType < Raze::Handler
    def call(ctx, done)
      ctx.response.headers["Content-Type"] = "application/json"
      done.call
    end
  end
end
