# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI context menu component that appears on right-click or trigger element interaction.
    # Supports menu items with icons, shortcuts, badges, dividers, and headers.
    #
    # @example Basic context menu
    #   render Components::Preline::ContextMenu.new(
    #     items: [
    #       { text: "Edit", icon: "edit", href: "#edit" },
    #       { text: "Delete", icon: "trash", href: "#delete", variant: :danger }
    #     ]
    #   )
    #
    # @example Context menu with shortcuts and dividers
    #   render Components::Preline::ContextMenu.new(
    #     trigger_selector: ".file-item",
    #     items: [
    #       { text: "Cut", icon: "cut", shortcut: ["Cmd", "X"] },
    #       { text: "Copy", icon: "copy", shortcut: ["Cmd", "C"] },
    #       { text: "Paste", icon: "paste", shortcut: ["Cmd", "V"], disabled: true },
    #       { divider: true },
    #       { text: "Delete", icon: "trash", variant: :danger }
    #     ]
    #   )
    #
    # @example Context menu with headers and badges
    #   render Components::Preline::ContextMenu.new(
    #     items: [
    #       { header: "Actions" },
    #       { text: "Share", icon: "share", badge: "New" },
    #       { text: "Download", icon: "download" },
    #       { divider: true },
    #       { header: "Advanced" },
    #       { text: "Settings", icon: "cog" }
    #     ]
    #   )
    class ContextMenu < ::Components::Preline::PrelineComponent
      # Initialize a new ContextMenu component
      #
      # @param id [String, nil] Optional HTML ID (auto-generated if not provided)
      # @param items [Array<Hash>] Menu items configuration
      # @option items [String] :text Item text content
      # @option items [String] :icon Font Awesome icon name
      # @option items [String] :href Link URL (defaults to "#")
      # @option items [Array<String>] :shortcut Keyboard shortcut keys
      # @option items [String] :badge Badge text
      # @option items [Symbol] :variant Item variant (:danger for destructive actions)
      # @option items [Boolean] :disabled Whether item is disabled
      # @option items [Boolean] :divider Render as divider
      # @option items [String] :header Render as section header
      # @option items [Hash] :data Data attributes for the item
      # @param trigger_selector [String, nil] CSS selector for elements that trigger the menu
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        # Extract component-specific attributes
        @id = attrs.delete(:id) || "context-menu-#{SecureRandom.hex(4)}"
        @items = attrs.delete(:items) || []
        @trigger_selector = attrs.delete(:trigger_selector)

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:data, :aria, :role)

        # Remaining attributes
        @options = attrs.except(:data, :aria, :role, :class)
      end

      def view_template
        div(
          id: @id,
          class: menu_classes,
          data: context_menu_data,
          style: 'display: none; position: absolute;',
          **@html_attrs.merge(@options)
        ) do
          div(class: 'py-1') do
            @items.each do |item|
              render_menu_item(item)
            end
          end
        end

        yield if block_given?
      end

      private

      def menu_classes
        base = 'hs-context-menu z-50 min-w-[12rem] bg-white border border-gray-200 rounded-lg shadow-md'
        [base, @custom_class].compact.join(' ')
      end

      def context_menu_data
        {
          'hs-context-menu': '',
          'hs-context-menu-trigger': @trigger_selector
        }.compact
      end

      def render_menu_item(item)
        if item[:divider]
          hr(class: 'my-1 border-gray-200')
        elsif item[:header]
          div(class: 'px-3 py-2 text-xs font-semibold text-gray-500 uppercase') do
            item[:header]
          end
        else
          a(
            href: item[:href] || '#',
            class: menu_item_classes(item),
            data: item[:data]
          ) do
            i(class: "fas fa-#{item[:icon]} mr-2 text-gray-400") if item[:icon]

            span { item[:text] }

            if item[:shortcut]
              span(class: 'ml-auto') do
                render Components::Preline::Kbd.new(keys: item[:shortcut], size: :xs)
              end
            end

            if item[:badge]
              span(class: 'ml-auto inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800') do
                item[:badge]
              end
            end
          end
        end
      end

      def menu_item_classes(item)
        base = 'flex items-center px-3 py-2 text-sm text-gray-700 hover:bg-gray-100'

        state_classes = []
        state_classes << 'text-red-600 hover:bg-red-50' if item[:variant] == :danger
        state_classes << 'opacity-50 cursor-not-allowed' if item[:disabled]

        [base, state_classes].flatten.compact.join(' ')
      end
    end
  end
end
