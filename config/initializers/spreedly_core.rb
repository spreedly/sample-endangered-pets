require Rails.root + "app/models/spreedly_core"

config = YAML.load_file(Rails.root + "config/spreedly_core.yml")
SpreedlyCore.configure(config['api_login'], config['api_secret'], config['gateway_token'])

