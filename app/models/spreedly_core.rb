class SpreedlyCore
  def self.config_file
    File.expand_path(Rails.root.join('config', 'spreedly_core.yml'))
  end

  def self.config
    @config ||= YAML.load(ERB.new(File.read(config_file)).result).with_indifferent_access
  end

  def self.core_domain
    config[:core_domain] || "https://spreedlycore.com"
  end


  include HTTParty
  headers 'Accept' => 'text/xml'
  headers 'Content-Type' => 'text/xml'
  basic_auth(config[:api_login], config[:api_secret])
  base_uri("#{core_domain}/v1")
  format :xml

  def self.api_login
    config[:api_login]
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

  def self.add_payment_method_url
    "#{core_domain}/v1/payment_methods"
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
    self.post("/gateways/#{config[:payment_methods][payment_method.type]}/#{action}.xml", body: self.to_xml_params(transaction: transaction))
  end
end
