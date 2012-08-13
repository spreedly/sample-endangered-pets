if Rails.env.development? || Rails.env.test?
  LogBuddy.init(use_awesome_print: true)
end
