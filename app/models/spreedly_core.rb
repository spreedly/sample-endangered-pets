class SpreedlyCore

  include HTTParty
  headers 'Accept' => 'text/xml'
  headers 'Content-Type' => 'text/xml'
  basic_auth(ENV["CORE_ENVIRONMENT_KEY"], ENV["CORE_ACCESS_SECRET"])
  base_uri("#{ENV["CORE_DOMAIN"]}/v1")
  format :xml


  def self.environment_key
    ENV["CORE_ENVIRONMENT_KEY"]
  end

  def self.purchase(payment_method_token, amount, currency_code="USD")
    post_transaction("purchase", payment_method_token, amount, currency_code)
  end

  def self.authorize(payment_method_token, amount, currency_code="USD")
    post_transaction("authorize", payment_method_token, amount, currency_code)
  end

  def self.get_payment_method(token)
    self.get("/payment_methods/#{token}.xml")
  end

  def self.add_payment_method_url
    "#{ENV["CORE_DOMAIN"]}/v1/payment_methods"
  end

  private
    def self.to_xml_params(hash)
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

    def self.post_transaction(action, payment_method_token, amount, currency_code="USD")
      transaction = { :amount => amount, :currency_code => currency_code, :payment_method_token => payment_method_token }
      self.post("/gateways/#{ENV["CORE_GATEWAY_FOR_CREDIT_CARD"]}/#{action}.xml", :body => self.to_xml_params(:transaction => transaction))
    end

end
