module Hurl
  class HurlException < Exception
  end

  # Exception for Invalid URIs
  class InvalidURI < HurlException
  end

  # Exception for Invalid TTL values
  class InvalidTTL < HurlException
  end
  
  # Exception to raise when an invalid code is given
  class InvalidCode < HurlException
  end
end
