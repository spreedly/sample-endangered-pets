class CryptoHash

  def self.new_hex_token
    ActiveSupport::SecureRandom.hex(16)
  end
  
  def self.secure_digest(*args)
    digest = args.flatten.join("-=====-")
    Digest::SHA384.hexdigest(digest) 
  end

end
