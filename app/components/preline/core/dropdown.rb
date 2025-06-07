# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI dropdown component for creating contextual overlay menus.
    # Supports flexible positioning, custom triggers, and various item types.
    #
    # @example Basic dropdown
    #   render Components::Preline::Dropdown.new(
    #     trigger_text: "Options",
    #     items: [
    #       { text: "Edit", href: "/edit" },
    #       { text: "Delete", href: "/delete" }
    #     ]
    #   )
    #
    # @example Dropdown with icons and dividers
    #   render Components::Preline::Dropdown.new(
    #     trigger_text: "Actions",
    #     trigger_icon: "cog",
    #     trigger_variant: :primary,
    #     placement: :"bottom-end",
    #     items: [
    #       { text: "View", icon: "eye", href: "/view" },
    #       { text: "Edit", icon: "edit", href: "/edit" },
    #       { divider: true },
    #       { text: "Delete", icon: "trash", variant: :danger }
    #     ]
    #   )
    class Dropdown < ::Components::Preline::PrelineComponent
      PLACEMENTS = {
        'bottom-start': 'bottom-start',
        'bottom-end': 'bottom-end',
        'top-start': 'top-start',
        'top-end': 'top-end',
        'left-start': 'left-start',
        'left-end': 'left-end',
        'right-start': 'right-start',
        'right-end': 'right-end'
      }.freeze

      # @param trigger_text [String] Text for the dropdown trigger button
      # @param trigger_variant [Symbol] Button variant (:primary, :secondary, :danger, etc.)
      # @param trigger_size [Symbol] Button size (:sm, :md, :lg)
      # @param trigger_icon [String] Optional FontAwesome icon name for trigger
      # @param trigger_class [String] Additional CSS classes for trigger button
      # @param items [Array<Hash>] Array of dropdown items with :text, :href, :icon, etc.
      # @param placement [Symbol] Dropdown placement (:"bottom-start", :"bottom-end", :"top-start", etc.)
      # @param offset [Integer] Offset from trigger in pixels (default: 10)
      # @param menu_class [String] Additional CSS classes for dropdown menu
      # @param id [String] Optional dropdown ID (auto-generated if not provided)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        trigger_text:,
        trigger_variant: :secondary,
        trigger_size: :md,
        trigger_icon: nil,
        trigger_class: '',
        items: [],
        placement: :'bottom-start',
        offset: 10,
        menu_class: '',
        id: nil,
        **attrs
      )
        # Validate parameters - trigger_text is required unless there's an icon
        @trigger_text = if trigger_icon.nil? || trigger_icon.to_s.empty?
                          validate_required!(trigger_text, 'trigger_text')
                        else
                          trigger_text
                        end
        @trigger_variant = trigger_variant
        @trigger_size = trigger_size
        @trigger_icon = trigger_icon
        @trigger_class = validate_css_class!(trigger_class)
        @items = validate_array!(items, 'items')
        @placement = validate_inclusion!(placement, 'placement', PLACEMENTS.keys)
        @offset = validate_integer!(offset, 'offset')
        @menu_class = validate_css_class!(menu_class)
        @id = validate_html_id!(id) || cached_id('dropdown')

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template(&block)
        code_path 'Renders dropdown component'
        wrapper_attrs = component_attributes(additional_classes: build_wrapper_classes)

        div(**wrapper_attrs) do
          render_trigger
          render_menu(&block)
        end
      end

      def dropdown_item(
        text: nil,
        href: nil,
        icon: nil,
        divider: false,
        header: false,
        disabled: false,
        active: false,
        variant: nil,
        **options
      )
        if divider
          code_path 'Renders dropdown divider'
          div(class: 'hs-dropdown-divider')
        elsif header
          code_path 'Renders dropdown header'
          h6(class: 'hs-dropdown-header') { text }
        else
          code_path 'Renders dropdown item'
          link_options = {
            class: build_item_classes(active, disabled, variant),
            href: href || '#',
            **options
          }

          a(**link_options) do
            if icon
              code_path 'Renders dropdown item with icon'
              render_icon(icon, additional_classes: 'hs-dropdown-item-icon')
            end

            if block_given?
              yield
            else
              plain text
            end
          end
        end
      end

      private

      def render_trigger
        button(
          type: 'button',
          id: @id,
          class: build_trigger_classes,
          data: {
            'hs-dropdown-toggle': '',
            'hs-dropdown-placement': @placement,
            'hs-dropdown-offset': @offset
          },
          aria: {
            haspopup: true,
            expanded: false
          }
        ) do
          if @trigger_icon
            code_path 'Renders trigger with icon'
            render_icon(@trigger_icon, additional_classes: @trigger_text.present? ? 'mr-2' : '')
          end

          if @trigger_text.present?
            code_path 'Renders trigger with text'
            span { @trigger_text }
          end

          # Only show dropdown arrow if not using ellipsis icons
          unless @trigger_icon&.include?('ellipsis')
            code_path 'Renders dropdown arrow'
            svg(
              class: 'hs-dropdown-toggle-icon ml-2',
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

      def render_menu
        div(
          class: "hs-dropdown-menu #{@menu_class}".strip,
          aria: { labelledby: @id },
          role: 'menu'
        ) do
          if block_given?
            code_path 'Renders dropdown with custom content'
            yield
          else
            code_path 'Renders dropdown with items array'
            render_items
          end
        end
      end

      def render_items
        @items.each do |item|
          dropdown_item(**item)
        end
      end

      def build_trigger_classes
        classes = ['hs-dropdown-toggle']
        classes += Components::Preline::Button::VARIANTS[@trigger_variant].to_s.split if @trigger_variant
        classes += Components::Preline::Button::SIZES[@trigger_size].to_s.split if @trigger_size
        classes << @trigger_class
        classes.join(' ').strip
      end

      def build_item_classes(active, disabled, variant)
        classes = ['hs-dropdown-item']
        if active
          code_path 'Renders active dropdown item'
          classes << 'hs-dropdown-item-active'
        end
        if disabled
          code_path 'Renders disabled dropdown item'
          classes << 'hs-dropdown-item-disabled'
        end
        if variant
          code_path 'Renders dropdown item with variant'
          classes << "hs-dropdown-item-#{variant}"
        end
        classes.join(' ').strip
      end

      def build_wrapper_classes
        ['hs-dropdown']
      end
    end
  end
end
