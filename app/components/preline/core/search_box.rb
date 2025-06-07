# frozen_string_literal: true

module Components
  module Preline
    # A search input component with dropdown suggestions and controls
    #
    # This component provides a search interface with:
    # - Search icon and input field
    # - Optional clear button
    # - Optional search submit button
    # - Dropdown suggestions/autocomplete
    # - Size variants (small, default, large)
    # - Keyboard navigation support
    #
    # @example Basic search box
    #   SearchBox(placeholder: "Search products...")
    #
    # @example With suggestions dropdown
    #   SearchBox(
    #     name: "product_search",
    #     placeholder: "Search by name or SKU",
    #     suggestions: [
    #       { text: "iPhone 15", href: "/products/1", icon: "mobile" },
    #       { text: "MacBook Pro", href: "/products/2", icon: "laptop" },
    #       { text: "AirPods", href: "/products/3", icon: "headphones" }
    #     ]
    #   )
    #
    # @example Large size with value
    #   SearchBox(
    #     name: "global_search",
    #     placeholder: "Search everything...",
    #     value: "customer",
    #     size: :lg,
    #     dropdown: true
    #   )
    #
    # @example Without buttons
    #   SearchBox(
    #     name: "inline_search",
    #     placeholder: "Filter results",
    #     clear_button: false,
    #     search_button: false
    #   )
    #
    # @example With metadata in suggestions
    #   SearchBox(
    #     suggestions: [
    #       { text: "John Doe", href: "/users/1", meta: "Customer" },
    #       { text: "Jane Smith", href: "/users/2", meta: "Admin" }
    #     ]
    #   )
    class SearchBox < ::Components::Preline::PrelineComponent
      # Initializes a new search box component
      #
      # @param name [String] Input field name attribute (default: "search")
      # @param attrs [Hash] Additional attributes
      # @option attrs [String] :id Custom ID (auto-generated if not provided)
      # @option attrs [String] :placeholder Placeholder text (default: "Search...")
      # @option attrs [String] :value Initial search value
      # @option attrs [Symbol] :size Size variant (:sm, :default, :lg) (default: :default)
      # @option attrs [Boolean] :dropdown Enable dropdown container (default: false)
      # @option attrs [Array<Hash>] :suggestions Array of suggestion items with :text, :href, :icon, :meta
      # @option attrs [Boolean] :clear_button Show clear button (default: true)
      # @option attrs [Boolean] :search_button Show search button (default: true)
      # @option attrs [Boolean] :disabled Whether the input is disabled (default: false)
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :data Data attributes
      # @option attrs [Hash] :aria ARIA attributes
      def initialize(name: 'search', **attrs)
        @name = name
        @id = attrs.delete(:id) || "search_box_#{SecureRandom.hex(4)}"
        @placeholder = attrs.delete(:placeholder) || 'Search...'
        @value = attrs.delete(:value)
        @size = attrs.delete(:size) || :default
        @dropdown = attrs.delete(:dropdown) || false
        @suggestions = attrs.delete(:suggestions) || []
        @clear_button = attrs.key?(:clear_button) ? attrs.delete(:clear_button) : true
        @search_button = attrs.key?(:search_button) ? attrs.delete(:search_button) : true
        @disabled = attrs.key?(:disabled) ? attrs.delete(:disabled) : false

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs.except(:data), class: wrapper_classes, data: search_box_data) do
          div(class: 'relative') do
            # Search icon
            div(class: search_icon_classes) do
              render_search_icon
            end

            # Input field
            input(
              type: 'search',
              id: @id,
              name: @name,
              value: @value,
              placeholder: @placeholder,
              disabled: @disabled,
              autocomplete: 'off',
              **@options,
              class: input_classes,
              data: { 'hs-search-box-input': '' }
            )

            # Clear button
            if @clear_button
              button(
                type: 'button',
                class: clear_button_classes,
                data: { 'hs-search-box-clear': '' },
                style: @value.blank? ? 'display: none;' : ''
              ) do
                render_clear_icon
              end
            end

            # Search button
            if @search_button
              button(
                type: 'submit',
                class: search_button_classes,
                disabled: @disabled
              ) do
                plain 'Search'
              end
            end
          end

          # Dropdown suggestions
          render_dropdown if @dropdown || @suggestions.any?

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        base = ['hs-search-box', size_class]
        [base, @custom_class].flatten.compact.join(' ')
      end

      def size_class
        case @size
        when :sm then 'hs-search-box-sm'
        when :lg then 'hs-search-box-lg'
        else ''
        end
      end

      def search_icon_classes
        'absolute inset-y-0 start-0 flex items-center pointer-events-none ps-3'
      end

      def input_classes
        base = 'hs-search-box-input block w-full border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500'
        padding = @search_button ? 'ps-10 pe-24' : 'ps-10 pe-10'
        size_padding = case @size
                       when :sm then 'py-1.5 text-sm'
                       when :lg then 'py-3 text-lg'
                       else 'py-2'
                       end

        [base, padding, size_padding].join(' ')
      end

      def search_box_data
        base_data = { 'hs-search-box': '' }
        custom_data = @html_attrs[:data] || {}
        base_data.merge(custom_data)
      end

      def clear_button_classes
        'hs-search-box-clear absolute inset-y-0 end-20 flex items-center pe-3 cursor-pointer text-gray-400 hover:text-gray-600'
      end

      def search_button_classes
        base = 'hs-search-box-button absolute inset-y-0 end-0 flex items-center px-4 text-sm font-medium text-white bg-blue-600 rounded-e-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500'

        [base, 'disabled:opacity-50 disabled:cursor-not-allowed'].join(' ')
      end

      def render_dropdown
        div(
          class: 'hs-search-box-dropdown hidden absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg',
          data: { 'hs-search-box-dropdown': '' }
        ) do
          if @suggestions.any?
            ul(class: 'py-1') do
              @suggestions.each do |suggestion|
                li do
                  a(
                    href: suggestion[:href] || '#',
                    class: 'block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100',
                    data: { 'hs-search-box-suggestion': '' }
                  ) do
                    i(class: "fas fa-#{suggestion[:icon]} mr-2 text-gray-400") if suggestion[:icon]

                    span { suggestion[:text] }

                    span(class: 'ml-auto text-xs text-gray-500') { suggestion[:meta] } if suggestion[:meta]
                  end
                end
              end
            end
          else
            div(class: 'px-4 py-8 text-center text-sm text-gray-500') do
              'Start typing to see suggestions...'
            end
          end
        end
      end

      def render_search_icon
        svg(
          class: 'size-4 text-gray-400',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          viewBox: '0 0 24 24'
        ) do |s|
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z'
          )
        end
      end

      def render_clear_icon
        svg(
          class: 'size-4',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          viewBox: '0 0 24 24'
        ) do |s|
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M6 18L18 6M6 6l12 12'
          )
        end
      end
    end
  end
end
