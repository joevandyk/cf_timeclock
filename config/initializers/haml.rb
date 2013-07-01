require 'haml'

class HamlTemplate < Tilt::HamlTemplate
  def prepare
    @options = @options.merge :format => :html5
    super
  end
end

Rails.application.config.before_initialize do |app|
  require 'sprockets'
  Sprockets::Engines #force autoloading
  Sprockets.register_engine '.haml', HamlTemplate
end
