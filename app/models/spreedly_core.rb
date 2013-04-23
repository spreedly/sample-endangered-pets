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

  def self.purchase(payment_method, amount, options={})
    options[:amount] = amount
    post_transaction("purchase", payment_method, options)
  end

  def self.authorize(payment_method, amount, options={})
    options[:amount] = amount
    post_transaction("authorize", payment_method, options)
  end

  def self.get_payment_method(token)
    self.get("/payment_methods/#{token}.xml")
  end

  def self.get_transaction(token)
    self.get("/transactions/#{token}.xml")
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

  def self.post_transaction(action, payment_method, options)
    options[:currency_code] ||= "USD"
    transaction = {payment_method_token: payment_method.token}.merge(options)
    self.post("/gateways/#{env_var_for(payment_method)}/#{action}.xml", body: self.to_xml_params(transaction: transaction))
  end

  def self.env_var_for(payment_method)
    ENV["CORE_GATEWAY_FOR_#{payment_method.payment_method_type.upcase}"]
  end
end
