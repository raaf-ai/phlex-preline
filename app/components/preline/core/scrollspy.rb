# frozen_string_literal: true

module Components
  module Preline
    # Scrollspy component for navigation that highlights based on scroll position
    #
    # @example Basic scrollspy navigation
    #   Scrollspy(target: "content") do
    #     ScrollspyItem(href: "#section1") { "Introduction" }
    #     ScrollspyItem(href: "#section2") { "Features" }
    #     ScrollspyItem(href: "#section3") { "Pricing" }
    #   end
    #
    # @example Scrollspy with custom offset
    #   Scrollspy(target: "main-content", offset: 100) do
    #     ScrollspyItem(href: "#overview", active: true) { "Overview" }
    #     ScrollspyItem(href: "#details") { "Details" }
    #   end
    #
    # @example Styled scrollspy sidebar
    #   Scrollspy(target: "docs", class: "sticky top-20 w-64") do
    #     ul(class: "space-y-2") do
    #       li do
    #         ScrollspyItem(href: "#intro", class: "block p-2 rounded hover:bg-gray-100") { "Introduction" }
    #       end
    #       li do
    #         ScrollspyItem(href: "#api", class: "block p-2 rounded hover:bg-gray-100") { "API Reference" }
    #       end
    #     end
    #   end
    class Scrollspy < ::Components::Preline::PrelineComponent
      # @param target [String] ID of the scrollable container to spy on
      # @param offset [Integer] Offset in pixels from top when calculating active section
      # @param attrs [Hash] Additional HTML attributes for the scrollspy container
      # @option attrs [String] :class CSS classes to add to the scrollspy nav
      # @option attrs [String] :id HTML ID attribute
      # @option attrs [Hash] :data Additional data attributes
      def initialize(target: 'body', offset: 10, **attrs)
        @target = target
        @offset = offset
        @custom_class = attrs.delete(:class)
        @data_attrs = attrs.delete(:data) || {}
        @html_attrs = attrs
      end

      def view_template
        nav(
          **@html_attrs,
          class: scrollspy_classes,
          data: @data_attrs.merge({
                                    'hs-scrollspy': "##{@target}",
                                    'hs-scrollspy-offset': @offset
                                  })
        ) do
          yield if block_given?
        end
      end

      private

      def scrollspy_classes
        base = 'hs-scrollspy'
        [base, @custom_class].compact.join(' ')
      end
    end

    # ScrollspyItem component for individual navigation items
    #
    # @example Basic scrollspy item
    #   ScrollspyItem(href: "#section1") { "Section 1" }
    #
    # @example Active scrollspy item
    #   ScrollspyItem(href: "#current", active: true) { "Current Section" }
    #
    # @example Styled scrollspy item
    #   ScrollspyItem(
    #     href: "#features",
    #     class: "block px-4 py-2 text-sm transition-colors"
    #   ) do
    #     i(class: "fas fa-star mr-2")
    #     span { "Features" }
    #   end
    class ScrollspyItem < ::Components::Preline::PrelineComponent
      # @param href [String] The anchor link to the section
      # @param active [Boolean] Whether this item is currently active
      # @param attrs [Hash] Additional HTML attributes for the item
      # @option attrs [String] :class CSS classes to add to the item
      # @option attrs [String] :id HTML ID attribute
      # @option attrs [Hash] :data Additional data attributes
      def initialize(href:, active: false, **attrs)
        @href = href
        @active = active
        @custom_class = attrs.delete(:class)
        @data_attrs = attrs.delete(:data) || {}
        @html_attrs = attrs
      end

      def view_template
        a(
          href: @href,
          **@html_attrs,
          class: item_classes,
          data: @data_attrs.merge({ 'hs-scrollspy-item': '' })
        ) do
          yield if block_given?
        end
      end

      private

      def item_classes
        base = 'hs-scrollspy-item'
        active_class = @active ? 'hs-scrollspy-active' : ''

        [base, active_class, @custom_class].compact.join(' ')
      end
    end
  end
end
