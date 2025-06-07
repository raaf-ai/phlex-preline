# frozen_string_literal: true

module Components
  module Preline
    # A color picker component with visual preview and optional swatches
    #
    # This component provides a color selection interface with:
    # - Visual color preview
    # - Text input for manual color entry
    # - Native color picker integration
    # - Optional preset color swatches
    # - Support for different color formats (hex, rgb, etc.)
    #
    # @example Basic color picker
    #   ColorPicker(name: "theme_color", label: "Theme Color")
    #
    # @example With preset swatches
    #   ColorPicker(
    #     name: "brand_color",
    #     label: "Brand Color",
    #     value: "#3B82F6",
    #     swatches: ["#EF4444", "#10B981", "#3B82F6", "#8B5CF6"]
    #   )
    #
    # @example Required field with custom format
    #   ColorPicker(
    #     name: "primary_color",
    #     label: "Primary Color *",
    #     required: true,
    #     format: :rgb
    #   )
    #
    # @example Disabled state
    #   ColorPicker(
    #     name: "locked_color",
    #     label: "Locked Color",
    #     value: "#000000",
    #     disabled: true
    #   )
    class ColorPicker < ::Components::Preline::PrelineComponent
      # Initializes a new color picker component
      #
      # @param name [String] Input field name attribute
      # @param attrs [Hash] Additional attributes
      # @option attrs [String] :id Custom ID (auto-generated if not provided)
      # @option attrs [String] :value Initial color value (default: "#000000")
      # @option attrs [String] :label Label text for the input
      # @option attrs [Array<String>] :swatches Array of preset color values
      # @option attrs [Symbol] :format Color format (:hex, :rgb, :hsl) (default: :hex)
      # @option attrs [Boolean] :required Whether the field is required (default: false)
      # @option attrs [Boolean] :disabled Whether the input is disabled (default: false)
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :data Data attributes
      # @option attrs [Hash] :aria ARIA attributes
      def initialize(name:, **attrs)
        @name = name
        @id = attrs.delete(:id) || "color_picker_#{name}_#{SecureRandom.hex(4)}"
        @value = attrs.delete(:value) || '#000000'
        @label = attrs.delete(:label)
        @swatches = attrs.delete(:swatches) || []
        @format = attrs.delete(:format) || :hex
        @required = attrs.delete(:required) || false
        @disabled = attrs.delete(:disabled) || false

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs, class: wrapper_classes) do
          if @label
            label(for: @id, class: label_classes) do
              plain @label
              span(class: 'text-red-500 ml-1') { '*' } if @required
            end
          end

          div(class: 'hs-color-picker', data: { 'hs-color-picker': '' }) do
            # Color input wrapper
            div(class: 'flex items-center gap-x-2') do
              # Color preview
              div(class: color_preview_classes, style: "background-color: #{@value}")

              # Text input
              input(
                type: 'text',
                id: @id,
                name: @name,
                value: @value,
                disabled: @disabled,
                required: @required,
                **@options,
                class: input_classes,
                data: { 'hs-color-picker-input': '' }
              )

              # Native color picker trigger
              label(for: "#{@id}_picker", class: picker_button_classes) do
                render_picker_icon
              end

              input(
                type: 'color',
                id: "#{@id}_picker",
                value: @value,
                disabled: @disabled,
                class: 'sr-only',
                data: { 'hs-color-picker-native': '' }
              )
            end

            # Color swatches
            render_swatches if @swatches.any?
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        ['hs-color-picker-wrapper', @custom_class].compact.join(' ')
      end

      def label_classes
        'block text-sm font-medium text-gray-700 mb-2'
      end

      def color_preview_classes
        'hs-color-picker-preview w-10 h-10 rounded border border-gray-300'
      end

      def input_classes
        'hs-color-picker-input flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 disabled:opacity-50 disabled:cursor-not-allowed'
      end

      def picker_button_classes
        'hs-color-picker-trigger inline-flex items-center justify-center w-10 h-10 rounded-md border border-gray-300 bg-white hover:bg-gray-50 cursor-pointer'
      end

      def render_swatches
        div(class: 'mt-3') do
          div(class: 'text-xs text-gray-500 mb-2') { 'Quick colors:' }
          div(class: 'flex flex-wrap gap-2') do
            @swatches.each do |color|
              button(
                type: 'button',
                class: swatch_classes,
                style: "background-color: #{color}",
                data: {
                  'hs-color-picker-swatch': color,
                  color: color
                },
                title: color
              )
            end
          end
        end
      end

      def swatch_classes
        'hs-color-picker-swatch w-6 h-6 rounded border border-gray-300 cursor-pointer hover:scale-110 transition-transform'
      end

      def render_picker_icon
        svg(
          class: 'w-4 h-4',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          viewBox: '0 0 24 24'
        ) do |s|
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4z'
          )
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4z'
          )
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M14 3l6 6-9 9-6-6 9-9z'
          )
        end
      end
    end
  end
end
