# frozen_string_literal: true

module Components
  module Preline
    class Devices < ::Components::Preline::PrelineComponent
      DEVICE_TYPES = {
        iphone: { width: '375px', height: '812px', bezel: '20px', notch: true },
        ipad: { width: '820px', height: '1180px', bezel: '40px', notch: false },
        macbook: { width: '1280px', height: '800px', bezel: '60px', notch: false },
        desktop: { width: '1920px', height: '1080px', bezel: '20px', notch: false },
        android: { width: '360px', height: '740px', bezel: '15px', notch: false }
      }.freeze

      def initialize(device: :iphone, **attrs)
        @device = device
        @orientation = attrs.delete(:orientation) || :portrait
        @scale = attrs.delete(:scale) || 0.5
        @theme = attrs.delete(:theme) || :light
        @content_url = attrs.delete(:content_url)

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs, **@options, class: device_wrapper_classes) do
          div(class: device_classes, style: device_styles) do
            # Device frame
            div(class: frame_classes) do
              # Notch (for devices that have it)
              render_notch if device_config[:notch]

              # Screen
              div(class: screen_classes) do
                if @content_url
                  iframe(
                    src: @content_url,
                    class: 'w-full h-full border-0',
                    loading: 'lazy'
                  )
                elsif block_given?
                  yield
                else
                  div(class: 'flex items-center justify-center h-full text-gray-400') do
                    'Device Content'
                  end
                end
              end

              # Home indicator (for mobile devices)
              render_home_indicator if mobile_device?
            end
          end
        end
      end

      private

      def device_config
        DEVICE_TYPES[@device] || DEVICE_TYPES[:iphone]
      end

      def device_wrapper_classes
        ['hs-device-wrapper', 'inline-block', @custom_class].compact.join(' ')
      end

      def device_classes
        base = %w[hs-device relative mx-auto]
        theme_class = @theme == :dark ? 'bg-gray-900' : 'bg-gray-100'

        [base, theme_class, 'rounded-3xl', 'shadow-2xl', 'p-2'].join(' ')
      end

      def device_styles
        config = device_config
        width = @orientation == :landscape ? config[:height] : config[:width]
        height = @orientation == :landscape ? config[:width] : config[:height]

        "width: #{width}; height: #{height}; transform: scale(#{@scale});"
      end

      def frame_classes
        %w[hs-device-frame relative w-full h-full bg-black rounded-2xl overflow-hidden].join(' ')
      end

      def screen_classes
        %w[hs-device-screen absolute inset-0 bg-white overflow-hidden].join(' ')
      end

      def render_notch
        div(class: 'hs-device-notch absolute top-0 left-1/2 transform -translate-x-1/2 w-40 h-7 bg-black rounded-b-2xl z-10')
      end

      def render_home_indicator
        div(class: 'hs-device-home-indicator absolute bottom-2 left-1/2 transform -translate-x-1/2 w-32 h-1 bg-white/30 rounded-full')
      end

      def mobile_device?
        %i[iphone android].include?(@device)
      end
    end
  end
end
