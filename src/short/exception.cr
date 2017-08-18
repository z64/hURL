module Short
  class ShortException < Exception
  end

  # Exception for Invalid URIs
  class InvalidURI < ShortException
  end

  # Exception for Invalid TTL values
  class InvalidTTL < ShortException
  end
  
  # Exception to raise when an invalid code is given
  class InvalidCode < Exception
  end
end
