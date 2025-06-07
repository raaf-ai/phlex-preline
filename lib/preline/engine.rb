# frozen_string_literal: true

require 'rails/engine'

module Phlex
  module Preline
    class Engine < ::Rails::Engine
      isolate_namespace Phlex::Preline

      # Component autoloading is handled by the host application

      initializer 'preline.assets' do |app|
        app.config.assets.paths << root.join('app', 'assets', 'stylesheets')
        app.config.assets.paths << root.join('app', 'assets', 'javascripts')
      end

      initializer 'preline.locale' do |_app|
        config.i18n.load_path += Dir[root.join('config', 'locales', '*.yml')]
      end
    end
  end
end
