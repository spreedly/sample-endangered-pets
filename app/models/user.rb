class User < ActiveRecord::Base

  attr_accessor :password, :password_required

  before_save              :encrypt_password
  validates_presence_of    :email
  validates_presence_of    :password, :if => :password_required
  validates_uniqueness_of  :email, :case_sensitive => false


  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?

    u = find_by_email(email)
    u && u.authenticated?(password) ? u : nil
  end

  def encrypt(password)
    CryptoHash.secure_digest(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def encrypt_password
    return if password.blank?
    self.salt = CryptoHash.new_hex_token if new_record?
    self.crypted_password = encrypt(password)
  end

end
