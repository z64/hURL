require "http/client"
require "json"
require "./link"

module Hurl
  # REST API interface
  module REST
    # Creates a new redirect object
    def create(target : String, code : String? = nil, ttl : Int32? = nil)
      response = HTTP::Client.post(
        @host,
        HTTP::Headers{"User-Agent" => @user_agent},
        { target: target, code: code, ttl: ttl }.to_json
      )

      Link.from_json(response.body)
    end

    # Fetches an existing redirect object
    def get(code : String)
      response = HTTP::Client.get(
        "#{@host}/#{code}",
        HTTP::Headers{"Accept" => "application/json", "User-Agent" => @user_agent}
      )
      Link.from_json(response.body) if response
    end
  end

  # Client for creating and requesting URLs
  # from a service running hURL
  class Client
    include REST

    # URL of host running hURL
    getter host : String

    # The User-Agent to make requests as
    property user_agent : String

    def initialize(@host, @user_agent = "hURL Client")
    end
  end
end
