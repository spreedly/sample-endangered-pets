module LayoutHelper
  
  def flash_class
    return "" if flash.values.empty?
    "#{flash.keys.join(' ')}"
  end
  
  def flash_value
    return nil if flash.values.join.blank?
    flash.values.collect { | value | "<p>#{h(value)}</p>"}.join("\n").html_safe
  end
  
end
