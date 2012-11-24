class SpreedlyCore

  def self.config_file
    File.expand_path(Rails.root.join('config', 'spreedly_core.yml'))
  end

  def self.config
    @config ||= YAML.load(ERB.new(File.read(config_file)).result).with_indifferent_access
  end


  include HTTParty
  headers 'Accept' => 'text/xml'
  headers 'Content-Type' => 'text/xml'
  basic_auth(config[:api_login], config[:api_secret])
  base_uri("#{config[:core_domain]}/v1")
  format :xml


  def self.api_login
    config[:api_login]
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
    "#{config[:core_domain]}/v1/payment_methods"
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
      self.post("/gateways/#{config[:gateway_token_for_payment_method][:credit_card]}/#{action}.xml", :body => self.to_xml_params(:transaction => transaction))
    end

end
