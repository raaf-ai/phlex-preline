# frozen_string_literal: true

module Components
  module Preline
    class AdvancedSelect < ::Components::Preline::PrelineComponent
      def initialize(name:, options:, **attrs)
        @name = name
        @options = options
        @selected = attrs.delete(:selected) || []
        @multiple = attrs.delete(:multiple) || false
        @searchable = attrs.delete(:searchable) || true
        @placeholder = attrs.delete(:placeholder) || 'Select...'
        @search_placeholder = attrs.delete(:search_placeholder) || 'Search...'
        @max_items = attrs.delete(:max_items)
        @tags = attrs.delete(:tags) || false
        @clearable = attrs.delete(:clearable) || true
        @disabled = attrs.delete(:disabled) || false
        @groups = attrs.delete(:groups) || false

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders advanced select component'
        div(**@html_attrs, **@options, class: wrapper_classes, data: select_data) do
          # Hidden input(s) to store selected values
          render_hidden_inputs

          # Select trigger
          div(
            class: trigger_classes,
            data: { 'hs-advanced-select-toggle': '' },
            tabindex: '0'
          ) do
            div(class: 'flex items-center justify-between') do
              # Selected items display
              div(class: 'flex-1') do
                if @selected.empty?
                  span(class: 'text-gray-400') { @placeholder }
                elsif @tags && @multiple
                  render_tags
                else
                  render_selected_text
                end
              end

              # Actions
              div(class: 'flex items-center ml-2') do
                # Clear button
                if @clearable && !@selected.empty? && !@disabled
                  button(
                    type: 'button',
                    class: 'text-gray-400 hover:text-gray-600 mr-2',
                    data: { 'hs-advanced-select-clear': '' }
                  ) do
                    render_clear_icon
                  end
                end

                # Dropdown arrow
                render_chevron_icon
              end
            end
          end

          # Dropdown panel
          div(
            class: dropdown_classes,
            data: { 'hs-advanced-select-dropdown': '' }
          ) do
            # Search input
            if @searchable
              code_path 'Renders with searchable'
              div(class: 'p-2 border-b') do
                input(
                  type: 'text',
                  class: search_input_classes,
                  placeholder: @search_placeholder,
                  data: { 'hs-advanced-select-search': '' }
                )
              end
            end

            # Options list
            div(class: 'max-h-60 overflow-y-auto py-1') do
              if @groups
                code_path 'Renders with groups'
                render_grouped_options
              else
                render_options
              end
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        ['hs-advanced-select', 'relative', @custom_class].compact.join(' ')
      end

      def trigger_classes
        base = 'hs-advanced-select-trigger block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm bg-white cursor-pointer'
        disabled_class = @disabled ? 'opacity-50 cursor-not-allowed' : 'hover:border-gray-400'

        [base, disabled_class].join(' ')
      end

      def dropdown_classes
        'hs-advanced-select-dropdown hidden absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg'
      end

      def search_input_classes
        'w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
      end

      def select_data
        {
          'hs-advanced-select': '',
          'hs-advanced-select-multiple': @multiple.to_s,
          'hs-advanced-select-max-items': @max_items,
          'hs-advanced-select-tags': @tags.to_s
        }.compact
      end

      def render_hidden_inputs
        if @multiple
          code_path 'Renders with multiple'
          @selected.each do |value|
            input(type: 'hidden', name: "#{@name}[]", value: value)
          end
        else
          input(type: 'hidden', name: @name, value: @selected.first)
        end
      end

      def render_tags
        div(class: 'flex flex-wrap gap-1') do
          @selected.each do |value|
            option = find_option(value)
            next unless option

            span(class: 'inline-flex items-center px-2 py-1 text-xs font-medium text-blue-800 bg-blue-100 rounded-md') do
              plain option[:label] || option[:text]
              button(
                type: 'button',
                class: 'ml-1 text-blue-600 hover:text-blue-800',
                data: {
                  'hs-advanced-select-remove': '',
                  value: value
                }
              ) do
                render_remove_icon
              end
            end
          end
        end
      end

      def render_selected_text
        selected_options = @selected.map { |v| find_option(v) }.compact
        labels = selected_options.map { |o| o[:label] || o[:text] }
        plain labels.join(', ')
      end

      def render_options
        @options.each do |option|
          render_option(option)
        end
      end

      def render_grouped_options
        @options.each do |group|
          div do
            div(class: 'px-3 py-2 text-xs font-semibold text-gray-500 uppercase') do
              group[:label]
            end

            group[:options].each do |option|
              render_option(option)
            end
          end
        end
      end

      def render_option(option)
        selected = @selected.include?(option[:value])

        div(
          class: option_classes(selected),
          data: {
            'hs-advanced-select-option': '',
            value: option[:value],
            label: option[:label] || option[:text]
          }
        ) do
          if @multiple
            code_path 'Renders with multiple'
            input(
              type: 'checkbox',
              class: 'mr-2 text-blue-600',
              checked: selected
            )
          end

          i(class: "fas fa-#{option[:icon]} mr-2 text-gray-400") if option[:icon]

          span { option[:label] || option[:text] }

          span(class: 'block text-xs text-gray-500') { option[:description] } if option[:description]
        end
      end

      def option_classes(selected)
        base = 'px-3 py-2 cursor-pointer hover:bg-gray-100'
        selected_class = selected ? 'bg-blue-50 text-blue-700' : ''

        [base, selected_class].join(' ')
      end

      def find_option(value)
        if @groups
          code_path 'Renders with groups'
          @options.each do |group|
            option = group[:options].find { |o| o[:value] == value }
            return option if option
          end
          nil
        else
          @options.find { |o| o[:value] == value }
        end
      end

      def render_clear_icon
        svg(class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24') do |s|
          s.path(stroke_linecap: 'round', stroke_linejoin: 'round', stroke_width: '2', d: 'M6 18L18 6M6 6l12 12')
        end
      end

      def render_chevron_icon
        svg(class: 'w-4 h-4 text-gray-400', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24') do |s|
          s.path(stroke_linecap: 'round', stroke_linejoin: 'round', stroke_width: '2', d: 'M19 9l-7 7-7-7')
        end
      end

      def render_remove_icon
        svg(class: 'w-3 h-3', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24') do |s|
          s.path(stroke_linecap: 'round', stroke_linejoin: 'round', stroke_width: '2', d: 'M6 18L18 6M6 6l12 12')
        end
      end
    end
  end
end
