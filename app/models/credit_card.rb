class CreditCard
  include ActiveModel::Validations

  attr_accessor :first_name, :last_name, :card_type, :number, :verification_value, :month, :year, :how_many
  validates_presence_of :how_many
  validates_numericality_of :how_many, :only_integer => true
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
      self.how_many = attributes["data"].try(:[], "how_many")
    end

    def incorporate_errors_from_core
      doc = Hpricot(@core_response.body)
      doc.search("payment_method>errors>error").each do |each|
        errors.add(each.attributes['attribute'], I18n.t(each.attributes['key']))
      end
    end


end
