# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI accordion component for creating collapsible content panels.
    # Supports single or multiple open panels, always open mode, and customizable styling.
    #
    # @example Basic accordion with items
    #   render Components::Preline::Accordion.new(
    #     items: [
    #       { title: "Section 1", content: "Content 1", active: true },
    #       { title: "Section 2", content: "Content 2" }
    #     ]
    #   )
    #
    # @example Accordion with multiple panels open
    #   render Components::Preline::Accordion.new(multiple: true) do
    #     accordion.accordion_item(title: "FAQ 1", active: true) do
    #       p { "Answer to FAQ 1" }
    #     end
    #     accordion.accordion_item(title: "FAQ 2") do
    #       p { "Answer to FAQ 2" }
    #     end
    #   end
    #
    # @example Accordion with icons
    #   render Components::Preline::Accordion.new(
    #     items: [
    #       { title: "Settings", content: "Settings content", icon: "cog" },
    #       { title: "Profile", content: "Profile content", icon: "user" }
    #     ]
    #   )
    class Accordion < ::Components::Preline::PrelineComponent
      # Initialize a new Accordion component
      #
      # @param items [Array<Hash>] Array of accordion items with :title, :content, :active, :icon keys
      # @param multiple [Boolean] Allow multiple panels to be open simultaneously
      # @param always_open [Boolean] Prevent all panels from being closed
      # @param variant [Symbol] Visual variant (:default)
      # @param class [String] Additional CSS classes to apply
      # @param data [Hash] Additional data attributes
      def initialize(
        items: [],
        multiple: false,
        always_open: false,
        variant: :default,
        **attrs
      )
        @items = items
        @multiple = multiple
        @always_open = always_open
        @variant = variant
        @custom_class = attrs.delete(:class)
        @data = attrs.delete(:data) || {}
        @accordion_id = "accordion-#{SecureRandom.hex(4)}"
      end

      def view_template
        code_path 'Renders accordion component'
        div(
          class: "hs-accordion #{@custom_class}".strip,
          id: @accordion_id,
          data: build_data_attributes
        ) do
          if block_given?
            code_path 'Renders accordion with custom content'
            yield(self)
          else
            code_path 'Renders accordion with items array'
            render_items
          end
        end
      end

      # Render an individual accordion item/panel
      #
      # @param title [String] The title displayed in the accordion header
      # @param content [String, nil] The content to display when expanded (or use block)
      # @param active [Boolean] Whether this panel should be open by default
      # @param icon [String, nil] Font Awesome icon name to display before title
      # @param id [String, nil] Custom ID for the panel (auto-generated if not provided)
      # @yield Block content to render inside the accordion panel
      def accordion_item(
        title:,
        content: nil,
        active: false,
        icon: nil,
        id: nil
      )
        item_id = id || "item-#{SecureRandom.hex(4)}"

        code_path 'Renders active accordion item' if active

        div(class: "hs-accordion-item #{'hs-accordion-active' if active}") do
          h3(class: 'hs-accordion-header') do
            button(
              class: "hs-accordion-toggle #{'hs-accordion-toggle-collapsed' unless active}",
              type: 'button',
              data: {
                'hs-accordion-toggle': "##{item_id}"
              },
              aria: {
                expanded: active.to_s,
                controls: item_id
              }
            ) do
              render_toggle_content(title, icon)
            end
          end

          div(
            id: item_id,
            class: "hs-accordion-content #{'hs-accordion-content-show' if active}",
            aria: {
              labelledby: "#{item_id}-header"
            }
          ) do
            div(class: 'hs-accordion-body') do
              if block_given?
                code_path 'Renders accordion item with block content'
                yield(self)
              else
                code_path 'Renders accordion item with string content'
                plain content
              end
            end
          end
        end
      end

      private

      def build_data_attributes
        attrs = @data.dup
        if @always_open
          code_path 'Renders always open accordion'
          attrs['hs-accordion-always-open'] = @always_open.to_s
        end
        if @multiple
          code_path 'Renders multiple open accordion'
          attrs['hs-accordion-multiple'] = @multiple.to_s
        end
        attrs
      end

      def render_items
        @items.each_with_index do |item, index|
          accordion_item(
            title: item[:title],
            content: item[:content],
            active: item[:active] || (index.zero? && !@always_open),
            icon: item[:icon],
            id: item[:id]
          )
        end
      end

      def render_toggle_content(title, icon)
        if icon
          code_path 'Renders accordion item with icon'
          span(class: 'hs-accordion-toggle-icon') do
            i(class: "fas fa-#{icon}")
          end
        end

        span(class: 'hs-accordion-toggle-text') { title }

        span(class: 'hs-accordion-toggle-indicator') do
          svg(
            class: 'hs-accordion-toggle-rotate',
            width: '16',
            height: '16',
            viewBox: '0 0 16 16',
            fill: 'none',
            xmlns: 'http://www.w3.org/2000/svg'
          ) do |s|
            s.path(
              d: 'M2 5L8 11L14 5',
              stroke: 'currentColor',
              stroke_width: '2',
              stroke_linecap: 'round',
              stroke_linejoin: 'round'
            )
          end
        end
      end
    end
  end
end
