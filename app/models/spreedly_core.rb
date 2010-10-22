class SpreedlyCore
  
  BASE = "http://demo.pciinthecloud.com"

  include HTTParty
  headers 'Accept' => 'text/xml'
  headers 'Content-Type' => 'text/xml'
  base_uri "#{BASE}/v1"
  format :xml

  def self.configure(api_login, api_secret, gateway_token)
    basic_auth(api_login, api_secret)
    @api_login, @gateway_token = api_login, gateway_token
  end

  def self.api_login
    @api_login
  end

  def self.to_xml_params(hash) # :nodoc:
    hash.collect do |key, value|
      tag = key.to_s.tr('_', '-')
      result = "<#{tag}>"
      if value.is_a?(Hash)
        result << to_xml_params(value)
      else
        result << value.to_s
      end
      result << "</#{tag}>"
      result
    end.join('')
  end


  def self.purchase(payment_method_token, amount, currency_code="USD")
    post_transaction("purchase", payment_method_token, amount, currency_code)
  end

  def self.authorize(payment_method_token, amount, currency_code="USD")
    post_transaction("authorize", payment_method_token, amount, currency_code)
  end

  private
    def self.post_transaction(action, payment_method_token, amount, currency_code="USD")
      transaction = { :amount => amount, :currency_code => currency_code, :payment_method_token => payment_method_token }
      self.post("/gateways/#{@gateway_token}/#{action}.xml", :body => self.to_xml_params(:transaction => transaction))
    end


end
