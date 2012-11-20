$ ->
  $('#original_pay_with_card_button').click ->
    $('#other_payment_method_buttons').hide()
    $('#credit_card_form').removeClass("hidden")
    $('#original_pay_with_card_button').hide()
