require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"

Bundler.require(:default, Rails.env)

module CfTimeclockRails
  class Application < Rails::Application
  end
end
