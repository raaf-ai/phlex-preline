# frozen_string_literal: true

module Components
  module Preline
    class ComboBox < ::Components::Preline::PrelineComponent
      def initialize(name:, options:, **attrs)
        @name = name
        @options = options
        @value = attrs.delete(:value) || ''
        @placeholder = attrs.delete(:placeholder) || 'Type to search...'
        @allow_custom = attrs.delete(:allow_custom) || false
        @min_chars = attrs.delete(:min_chars) || 1
        @max_results = attrs.delete(:max_results) || 10
        @disabled = attrs.delete(:disabled) || false
        @required = attrs.delete(:required) || false
        @label = attrs.delete(:label)
        @async_url = attrs.delete(:async_url)

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @other_attrs = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders combo box component'
        div(**@html_attrs, **@other_attrs, class: wrapper_classes) do
          if @label
            code_path 'Renders combo box with label'
            label(class: label_classes) do
              plain @label
              if @required
                code_path 'Renders required indicator'
                span(class: 'text-red-500 ml-1') { '*' }
              end
            end
          end

          div(class: 'relative', data: combo_box_data) do
            # Input field
            div(class: 'relative') do
              code_path 'Renders disabled combo box' if @disabled
              input(
                type: 'text',
                name: @allow_custom ? @name : nil,
                value: @value,
                placeholder: @placeholder,
                disabled: @disabled,
                required: @required,
                autocomplete: 'off',
                class: input_classes,
                data: { 'hs-combo-box-input': '' }
              )

              # Loading spinner
              if @async_url
                code_path 'Renders async loading spinner'
                div(
                  class: 'absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none hidden',
                  data: { 'hs-combo-box-loading': '' }
                ) do
                  render_spinner
                end
              end
            end

            # Hidden input for selected value
            unless @allow_custom
              code_path 'Renders hidden value input'
              input(
                type: 'hidden',
                name: @name,
                value: @value,
                data: { 'hs-combo-box-value': '' }
              )
            end

            # Dropdown
            div(
              class: dropdown_classes,
              data: { 'hs-combo-box-dropdown': '' }
            ) do
              # Results container
              div(
                class: 'py-1',
                data: { 'hs-combo-box-results': '' }
              ) do
                if @options.any?
                  code_path 'Renders combo box options'
                  render_options(@options)
                else
                  code_path 'Renders empty state'
                  render_empty_state
                end
              end

              # Custom value option
              if @allow_custom
                code_path 'Renders custom value option'
                div(
                  class: 'hidden border-t',
                  data: { 'hs-combo-box-custom': '' }
                ) do
                  div(class: 'px-3 py-2 text-sm text-gray-600') do
                    plain 'Press Enter to use '
                    span(class: 'font-medium', data: { 'hs-combo-box-custom-text': '' })
                  end
                end
              end
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        ['hs-combo-box-wrapper', @custom_class].compact.join(' ')
      end

      def label_classes
        'block text-sm font-medium text-gray-700 mb-2'
      end

      def input_classes
        'hs-combo-box-input block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 disabled:opacity-50 disabled:cursor-not-allowed'
      end

      def dropdown_classes
        'hs-combo-box-dropdown hidden absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg max-h-60 overflow-y-auto'
      end

      def combo_box_data
        {
          'hs-combo-box': '',
          'hs-combo-box-allow-custom': @allow_custom.to_s,
          'hs-combo-box-min-chars': @min_chars,
          'hs-combo-box-max-results': @max_results,
          'hs-combo-box-async-url': @async_url
        }.compact
      end

      def render_options(options)
        options.each do |option|
          div(
            class: option_classes,
            data: {
              'hs-combo-box-option': '',
              value: option[:value],
              label: option[:label] || option[:text]
            }
          ) do
            if option[:icon]
              code_path 'Renders option with icon'
              i(class: "fas fa-#{option[:icon]} mr-2 text-gray-400")
            end

            div(class: 'flex-1') do
              div(class: 'font-medium') { option[:label] || option[:text] }
              if option[:description]
                code_path 'Renders option with description'
                div(class: 'text-xs text-gray-500') { option[:description] }
              end
            end

            if option[:meta]
              code_path 'Renders option with metadata'
              span(class: 'text-xs text-gray-400') { option[:meta] }
            end
          end
        end
      end

      def render_empty_state
        div(class: 'px-3 py-8 text-center text-sm text-gray-500') do
          'No results found'
        end
      end

      def option_classes
        'hs-combo-box-option px-3 py-2 cursor-pointer hover:bg-gray-100 flex items-center'
      end

      def render_spinner
        svg(
          class: 'animate-spin h-4 w-4 text-gray-400',
          fill: 'none',
          viewBox: '0 0 24 24'
        ) do |s|
          s.circle(
            class: 'opacity-25',
            cx: '12',
            cy: '12',
            r: '10',
            stroke: 'currentColor',
            stroke_width: '4'
          )
          s.path(
            class: 'opacity-75',
            fill: 'currentColor',
            d: 'M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z'
          )
        end
      end
    end
  end
end
