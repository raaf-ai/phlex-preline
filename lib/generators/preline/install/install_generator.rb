# frozen_string_literal: true

require 'rails/generators'

module Preline
  module Generators
    # Generator to install Preline JavaScript controllers and configure the application
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      class_option :skip_javascript, type: :boolean, default: false,
                                     desc: 'Skip JavaScript controller installation'
      class_option :importmap, type: :boolean, default: false,
                               desc: 'Use importmap-rails for JavaScript (auto-detected if not specified)'

      def install_javascript_controllers
        return if options[:skip_javascript]

        if use_importmap?
          install_with_importmap
        else
          install_with_node
        end
      end

      def copy_stylesheet
        source_file = File.join(gem_root, 'app/assets/stylesheets/preline-components.css')
        return say_status :skip, 'Could not find preline-components.css in gem', :yellow unless File.exist?(source_file)

        # Copy CSS file to the standard location
        # For tailwindcss-rails, this will be imported via @import in application.tailwind.css
        # For other setups, it can be imported in application.css/scss
        copy_file source_file, 'app/assets/tailwind/preline-components.css'
      end

      def add_stylesheet_import
        if File.exist?('app/assets/tailwind/application.css')
          say_status :insert, 'app/assets/tailwind/application.css'
          append_to_file 'app/assets/tailwind/application.css' do
            "\n/* Preline Components */\n@import 'preline-components';\n"
          end
        elsif File.exist?('app/assets/tailwind/application.scss')
          say_status :insert, 'app/assets/tailwind/application.scss'
          append_to_file 'app/assets/tailwind/application.scss' do
            "\n// Preline Components\n@import 'preline-components';\n"
          end
        else
          say_status :skip, 'Could not find application stylesheet', :yellow
          say 'Please manually import preline-components in your stylesheet', :yellow
        end
      end

      def show_post_install_message
        say "\n✨ Preline components installed successfully!\n", :green

        if use_importmap?
          say "\nUsing importmap-rails:", :blue
          say '  The Stimulus controllers are now available via importmap.'
          say '  No additional JavaScript bundling required!'
        else
          say "\nUsing node-based bundler:", :blue
          say '  Stimulus controllers have been copied to app/javascript/controllers/'
          say '  Make sure your bundler is configured to process these files.'
        end

        if use_tailwind_rails?
          say "\nUsing tailwindcss-rails:", :blue
          say '  CSS components have been added to app/assets/tailwind/'
          say '  The @import directive has been added to tailwind/application.css'
        end

        say "\nIMPORTANT: Tailwind CSS Configuration", :yellow
        say '  Add the gem\'s component paths to your tailwind.config.js:'
        say '  '
        say '  content: ['
        say '    \'./app/**/*.{erb,haml,html,slim,rb}\','
        say '    \'./vendor/bundle/**/gems/phlex-preline-*/app/components/**/*.rb\','
        say '  ]'

        say "\nNext steps:", :blue
        say '  1. Update your tailwind.config.js as shown above'
        say '  2. Restart your Rails server'
        say '  3. Run your Tailwind CSS build process if needed'
        say '  4. Start using Preline components in your views:'
        say "\n     render Components::Preline::Button.new(text: 'Click me!', variant: :primary)"
        say "\n📚 Full documentation: https://github.com/yourusername/phlex-preline\n"
      end

      private

      def use_importmap?
        return true if options[:importmap]
        return false if defined?(Webpacker) || File.exist?('config/webpacker.yml')
        return false if File.exist?('vite.config.ts') || File.exist?('vite.config.js')
        return false if File.exist?('esbuild.config.js')

        # Check if importmap-rails is in Gemfile
        File.read('Gemfile').include?('importmap-rails')
      rescue StandardError
        false
      end

      def use_tailwind_rails?
        # Check if using tailwindcss-rails gem
        File.exist?('app/assets/stylesheets/application.tailwind.css') ||
          (File.exist?('Gemfile') && File.read('Gemfile').include?('tailwindcss-rails'))
      rescue StandardError
        false
      end

      def install_with_importmap
        say_status :info, 'Installing with importmap-rails...', :blue

        # Pin the Preline JavaScript modules
        say_status :append, 'config/importmap.rb'
        append_to_file 'config/importmap.rb' do
          <<~RUBY

            # Preline UI Components
            pin "@preline/file-upload", to: "preline/file_upload_controller.js"
            pin "@preline/file-upload-gallery", to: "preline/file_upload_gallery_controller.js"
            pin "@preline/single-image-upload", to: "preline/single_image_upload_controller.js"
          RUBY
        end

        # Update Stimulus index to import controllers
        stimulus_index = 'app/javascript/controllers/index.js'
        if File.exist?(stimulus_index)
          say_status :insert, stimulus_index
          append_to_file stimulus_index do
            <<~JS

              // Preline UI Components
              import FileUploadController from "@preline/file-upload"
              import FileUploadGalleryController from "@preline/file-upload-gallery"
              import SingleImageUploadController from "@preline/single-image-upload"

              application.register("file-upload", FileUploadController)
              application.register("file-upload-gallery", FileUploadGalleryController)
              application.register("single-image-upload", SingleImageUploadController)
            JS
          end
        else
          say_status :skip, 'Could not find app/javascript/controllers/index.js', :yellow
          create_file stimulus_index do
            <<~JS
              import { application } from "./application"

              // Preline UI Components
              import FileUploadController from "@preline/file-upload"
              import FileUploadGalleryController from "@preline/file-upload-gallery"
              import SingleImageUploadController from "@preline/single-image-upload"

              application.register("file-upload", FileUploadController)
              application.register("file-upload-gallery", FileUploadGalleryController)
              application.register("single-image-upload", SingleImageUploadController)
            JS
          end
        end
      end

      def install_with_node
        say_status :info, 'Installing with node-based bundler...', :blue

        # Copy controller files
        controllers = %w[
          file_upload_controller.js
          file_upload_gallery_controller.js
          single_image_upload_controller.js
        ]

        controllers.each do |controller|
          source_file = File.join(gem_root, 'app/assets/javascripts/controllers', controller)
          if File.exist?(source_file)
            copy_file source_file, "app/javascript/controllers/#{controller}"
          else
            say_status :skip, "Could not find #{controller}", :yellow
          end
        end

        # Update Stimulus index
        stimulus_index = 'app/javascript/controllers/index.js'
        return unless File.exist?(stimulus_index)

        say_status :insert, stimulus_index
        append_to_file stimulus_index do
          <<~JS

            // Preline UI Components
            import FileUploadController from "./file_upload_controller"
            import FileUploadGalleryController from "./file_upload_gallery_controller"
            import SingleImageUploadController from "./single_image_upload_controller"

            application.register("file-upload", FileUploadController)
            application.register("file-upload-gallery", FileUploadGalleryController)
            application.register("single-image-upload", SingleImageUploadController)
          JS
        end
      end

      def gem_root
        Gem::Specification.find_by_name('phlex-preline').gem_dir
      end
    end
  end
end
