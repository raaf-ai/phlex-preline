# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI breadcrumb component for hierarchical navigation.
    # Shows the current page location within a navigational hierarchy.
    #
    # @example Basic breadcrumb
    #   render Components::Preline::Breadcrumb.new(
    #     items: [
    #       { text: "Home", href: "/" },
    #       { text: "Products", href: "/products" },
    #       { text: "Electronics", href: "/products/electronics" },
    #       { text: "Laptop" }  # Current page (no href)
    #     ]
    #   )
    #
    # @example Breadcrumb with icons and custom separator
    #   render Components::Preline::Breadcrumb.new(
    #     items: [
    #       { text: "Dashboard", href: "/", icon: "home" },
    #       { text: "Settings", href: "/settings", icon: "cog" },
    #       { text: "Profile" }
    #     ],
    #     separator: :chevron
    #   )
    class Breadcrumb < ::Components::Preline::PrelineComponent
      # Initialize a new Breadcrumb component
      #
      # @param items [Array<Hash>] Array of breadcrumb items with :text, :href, and optional :icon keys
      # @param separator [String, Symbol] Separator between items ("/" or symbols :chevron, :arrow)
      # @param class [String] Additional CSS classes for the breadcrumb container
      # @param item_class [String] Additional CSS classes for each breadcrumb item
      def initialize(
        items: [],
        separator: '/',
        item_class: '',
        **attrs
      )
        @items = items
        @separator = separator
        @custom_class = attrs.delete(:class)
        @item_class = item_class
      end

      def view_template
        code_path 'Renders breadcrumb component'
        nav(aria: { label: 'Breadcrumb' }) do
          ol(class: "hs-breadcrumb #{@custom_class}".strip) do
            render_items
          end
        end
      end

      private

      def render_items
        @items.each_with_index do |item, index|
          is_last = index == @items.length - 1

          li(class: build_item_classes(is_last)) do
            if is_last || !item[:href]
              render_active_item(item)
            else
              render_link_item(item)
            end

            render_separator unless is_last
          end
        end
      end

      def render_link_item(item)
        a(href: item[:href], class: 'hs-breadcrumb-link') do
          render_item_content(item)
        end
      end

      def render_active_item(item)
        span(
          class: 'hs-breadcrumb-active',
          aria: { current: 'page' }
        ) do
          render_item_content(item)
        end
      end

      def render_item_content(item)
        if item[:icon]
          code_path 'Renders with icon'
          i(class: "fas fa-#{item[:icon]} mr-1")
        end

        plain item[:text]
      end

      def render_separator
        code_path 'Renders with separator'
        span(class: 'hs-breadcrumb-separator', aria: { hidden: 'true' }) do
          case @separator
          when :chevron
            svg(
              class: 'hs-breadcrumb-separator-icon',
              width: '16',
              height: '16',
              viewBox: '0 0 16 16',
              fill: 'currentColor'
            ) do |s|
              s.path(
                fill_rule: 'evenodd',
                d: 'M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708z',
                clip_rule: 'evenodd'
              )
            end
          when :arrow
            i(class: 'fas fa-arrow-right')
          else
            plain @separator.to_s
          end
        end
      end

      def build_item_classes(is_last)
        classes = ['hs-breadcrumb-item']
        classes << 'hs-breadcrumb-item-active' if is_last
        classes << @item_class
        classes.join(' ').strip
      end
    end
  end
end
