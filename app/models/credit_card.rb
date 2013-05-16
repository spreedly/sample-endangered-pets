class CreditCard
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :first_name, :last_name, :card_type, :number, :verification_value, :month, :year, :full_name
  validate :incorporate_errors_from_core

  def initialize(core_response = nil)
    @core_response = core_response
    initialize_attributes(core_response['payment_method']) if core_response
  end

  private

  def initialize_attributes(attributes = {})
    attributes.each do |key, value|
      begin
        send("#{key}=", value)
      rescue NoMethodError
      end
    end
  end

  def incorporate_errors_from_core
    puts @core_response.body
    doc = Nokogiri::XML(@core_response.body)
    doc.search("payment_method>errors>error").each do |each|
      errors.add(each.attributes['attribute'].to_s, I18n.t(each.attributes['key']))
    end
  end
end
