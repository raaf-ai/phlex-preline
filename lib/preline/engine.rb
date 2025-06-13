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
        app.config.assets.paths << root.join('app', 'assets', 'javascripts', 'controllers')
      end

      initializer 'preline.assets.precompile' do |app|
        app.config.assets.precompile += %w[preline-components.css]
        # Make individual controller files available
        app.config.assets.precompile += %w[
          preline/file_upload_controller.js
          preline/file_upload_gallery_controller.js
          preline/single_image_upload_controller.js
        ]
      end

      initializer 'preline.importmap', before: 'importmap' do |_app|
        # Make JavaScript modules available to importmap-rails
        if defined?(Importmap)
          # Ensure controllers are served from the correct path
          Importmap::Engine.config.importmap.cache_sweepers << root.join('app/assets/javascripts/controllers')
        end
      end

      initializer 'preline.locale' do |_app|
        config.i18n.load_path += Dir[root.join('config', 'locales', '*.yml')]
      end
    end
  end
end
