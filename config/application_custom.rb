# TODO this should go to deploy-repo or be env-ified
module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :pl
    config.i18n.available_locales = [:pl, :en]
  end
end
