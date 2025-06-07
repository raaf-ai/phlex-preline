# frozen_string_literal: true

module Components
  module Preline
    class CustomScrollbar < ::Components::Preline::PrelineComponent
      def initialize(**attrs)
        @height = attrs.delete(:height) || 'auto'
        @max_height = attrs.delete(:max_height) || '100%'
        @theme = attrs.delete(:theme) || :default
        @always_visible = attrs.delete(:always_visible) || false
        @track_color = attrs.delete(:track_color)
        @thumb_color = attrs.delete(:thumb_color)
        @hover_thumb_color = attrs.delete(:hover_thumb_color)
        @width = attrs.delete(:width) || 'thin'

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(
          **@html_attrs,
          **@options,
          class: scrollbar_classes,
          style: scrollbar_styles,
          data: scrollbar_data.merge(@html_attrs[:data] || {})
        ) do
          yield if block_given?
        end
      end

      private

      def scrollbar_classes
        base = %w[hs-custom-scrollbar overflow-auto]

        theme_class = case @theme
                      when :minimal then 'hs-scrollbar-minimal'
                      when :rounded then 'hs-scrollbar-rounded'
                      when :dark then 'hs-scrollbar-dark'
                      else 'hs-scrollbar-default'
                      end

        width_class = case @width
                      when :thin then 'hs-scrollbar-thin'
                      when :medium then 'hs-scrollbar-medium'
                      when :thick then 'hs-scrollbar-thick'
                      else ''
                      end

        visibility_class = @always_visible ? 'hs-scrollbar-always-visible' : 'hs-scrollbar-auto-hide'

        [base, theme_class, width_class, visibility_class, @custom_class].flatten.compact.join(' ')
      end

      def scrollbar_styles
        styles = []
        styles << "height: #{@height}" if @height != 'auto'
        styles << "max-height: #{@max_height}" if @max_height != '100%'

        # Custom scrollbar colors via CSS variables
        if @track_color || @thumb_color || @hover_thumb_color
          color_styles = []
          color_styles << "--scrollbar-track: #{@track_color}" if @track_color
          color_styles << "--scrollbar-thumb: #{@thumb_color}" if @thumb_color
          color_styles << "--scrollbar-thumb-hover: #{@hover_thumb_color}" if @hover_thumb_color
          styles.concat(color_styles)
        end

        styles.join('; ')
      end

      def scrollbar_data
        {
          'hs-custom-scrollbar': '',
          'hs-custom-scrollbar-theme': @theme.to_s
        }
      end
    end
  end
end
