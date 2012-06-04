module LayoutHelper

  def flash_value
    flash.collect do |key, value|
      %{<p class="#{key}">#{value}</p>}
    end.join("\n").html_safe
  end

end
