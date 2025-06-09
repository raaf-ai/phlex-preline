# frozen_string_literal: true

module Components
  module Preline
    # ListGroup component for displaying a vertical list of items
    # Creates a styled list container with optional borders and background
    #
    # @example Basic list group with yielding interface
    #   ListGroup do |list|
    #     list.item { "First item" }
    #     list.item { "Second item" }
    #     list.item { "Third item" }
    #   end
    #
    # @example List group with active and disabled items
    #   ListGroup do |list|
    #     list.item(active: true) { "Active item" }
    #     list.item { "Regular item" }
    #     list.item(disabled: true) { "Disabled item" }
    #   end
    #
    # @example List group with links and actions
    #   ListGroup do |list|
    #     list.item(href: "/dashboard") { "Dashboard" }
    #     list.item(action: true) { "Click me" }
    #     list.item(href: "/settings", active: true) { "Settings" }
    #   end
    #
    # @example List group with direct content
    #   ListGroup do
    #     ListGroupItem { "First item" }
    #     ListGroupItem { "Second item" }
    #     ListGroupItem { "Third item" }
    #   end
    #
    # @example Flush list group (no borders/background)
    #   ListGroup(flush: true) do |list|
    #     list.item { "Item without container styling" }
    #     list.item { "Another item" }
    #   end
    class ListGroup < ::Components::Preline::PrelineComponent
      # @param flush [Boolean] Whether to remove borders and background (flush style)
      # @param attrs [Hash] Additional HTML attributes and options
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :* Any other HTML attributes
      def initialize(flush: false, **attrs)
        @flush = flush
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.except(:flush)
        @options = attrs.slice(:flush)
      end

      def view_template(&block)
        ul(**html_attrs, class: list_group_classes, role: 'list') do
          if block_given?
            if block.parameters.any? { |type, _| %i[opt req].include?(type) }
              yield(self)
            else
              yield
            end
          end
        end
      end

      # Creates a list group item
      def item(active: false, disabled: false, action: false, href: nil, **attrs, &block)
        render ListGroupItem.new(
          active: active,
          disabled: disabled,
          action: action,
          href: href,
          **attrs,
          &block
        )
      end

      private

      attr_reader :flush, :custom_class, :html_attrs, :options

      def list_group_classes
        base = 'hs-list-group flex flex-col'
        flush_class = flush ? '' : 'bg-white border border-gray-200 rounded-lg'

        [base, flush_class, custom_class].compact.join(' ')
      end
    end

    # ListGroupItem component for individual items within a ListGroup
    # Can be rendered as static items, clickable buttons, or links
    #
    # @example Basic list item
    #   ListGroupItem { "Simple text item" }
    #
    # @example Active list item
    #   ListGroupItem(active: true) { "Currently selected" }
    #
    # @example Clickable list item (button)
    #   ListGroupItem(action: true) do
    #     "Click me"
    #   end
    #
    # @example Link list item
    #   ListGroupItem(href: "/details") do
    #     "View details"
    #   end
    #
    # @example Disabled list item
    #   ListGroupItem(disabled: true) do
    #     "This item is disabled"
    #   end
    #
    # @example Complex list item with icons and badges
    #   ListGroupItem(href: "/notifications") do
    #     div(class: "flex justify-between items-center w-full") do
    #       span { "Notifications" }
    #       Badge(variant: :primary) { "5" }
    #     end
    #   end
    class ListGroupItem < ::Components::Preline::PrelineComponent
      # @param active [Boolean] Whether this item is currently active/selected
      # @param disabled [Boolean] Whether this item is disabled
      # @param action [Boolean] Whether this item should be clickable (renders as button)
      # @param href [String, nil] URL if this item should be a link
      # @param attrs [Hash] Additional HTML attributes and options
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :* Any other HTML attributes
      def initialize(active: false, disabled: false, action: false, href: nil, **attrs)
        @active = active
        @disabled = disabled
        @action = action
        @href = href
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.except(:active, :disabled, :action, :href)
        @options = attrs.slice(:active, :disabled, :action, :href)
      end

      def view_template
        if href || action
          component = href ? :a : :button
          send(component, **component_attrs) do
            yield if block_given?
          end
        else
          li(**html_attrs, class: item_classes) do
            yield if block_given?
          end
        end
      end

      private

      attr_reader :active, :disabled, :action, :href, :custom_class, :html_attrs, :options

      def component_attrs
        attrs = html_attrs.merge(class: item_classes)
        attrs[:href] = href if href
        attrs[:type] = 'button' if action && !href
        attrs[:disabled] = true if disabled
        attrs
      end

      def item_classes
        base = 'hs-list-group-item flex items-center px-4 py-3'

        state_classes = []
        state_classes << (active ? 'bg-blue-50 text-blue-700' : 'bg-white')
        state_classes << (disabled ? 'opacity-50 cursor-not-allowed' : '')
        state_classes << (action && !disabled ? 'hover:bg-gray-50 cursor-pointer' : '')

        border_class = 'border-b last:border-b-0'

        [base, state_classes, border_class, custom_class].flatten.compact.join(' ')
      end
    end
  end
end
