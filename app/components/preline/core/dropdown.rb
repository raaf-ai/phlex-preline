# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI dropdown component for creating contextual overlay menus.
    # Supports flexible positioning, custom triggers, and various item types.
    #
    # @example Basic dropdown with yielding interface
    #   render Components::Preline::Dropdown.new(trigger_text: "Options") do |dropdown|
    #     dropdown.item(text: "Edit", href: "/edit")
    #     dropdown.item(text: "Delete", href: "/delete")
    #   end
    #
    # @example Dropdown with icons and dividers
    #   render Components::Preline::Dropdown.new(
    #     trigger_text: "Actions",
    #     trigger_icon: "cog",
    #     trigger_variant: :primary,
    #     placement: :"bottom-end"
    #   ) do |dropdown|
    #     dropdown.item(text: "View", icon: "eye", href: "/view")
    #     dropdown.item(text: "Edit", icon: "edit", href: "/edit")
    #     dropdown.divider
    #     dropdown.item(text: "Delete", icon: "trash", variant: :danger)
    #   end
    #
    # @example Dropdown with items array
    #   render Components::Preline::Dropdown.new(
    #     trigger_text: "Options",
    #     items: [
    #       { text: "Edit", href: "/edit" },
    #       { text: "Delete", href: "/delete" }
    #     ]
    #   )
    #
    # @example User account dropdown
    #   render Components::Preline::Dropdown.new(
    #     trigger_text: current_user.name,
    #     trigger_icon: "user-circle",
    #     placement: :"bottom-end"
    #   ) do |dropdown|
    #     dropdown.header(text: current_user.email)
    #     dropdown.divider
    #     dropdown.item(text: "Profile", href: "/profile", icon: "user")
    #     dropdown.item(text: "Settings", href: "/settings", icon: "cog")
    #     dropdown.item(text: "Billing", href: "/billing", icon: "credit-card")
    #     dropdown.divider
    #     dropdown.item(text: "Sign out", href: "/logout", icon: "sign-out-alt", variant: :danger)
    #   end
    #
    # @example Dropdown with custom content
    #   render Components::Preline::Dropdown.new(trigger_text: "Notifications", trigger_icon: "bell") do
    #     div(class: "p-4 max-w-sm") do
    #       h3(class: "font-semibold mb-2") { "Recent Notifications" }
    #       ul(class: "space-y-2") do
    #         notifications.each do |notification|
    #           li(class: "p-2 hover:bg-gray-100 rounded") do
    #             p(class: "text-sm") { notification.message }
    #             time(class: "text-xs text-gray-500") { notification.created_at }
    #           end
    #         end
    #       end
    #     end
    #   end
    #
    # @example Action dropdown with confirmation
    #   render Components::Preline::Dropdown.new(
    #     trigger_text: "Actions",
    #     trigger_variant: :secondary,
    #     trigger_size: :sm
    #   ) do |dropdown|
    #     dropdown.item(text: "Edit", href: edit_path, icon: "edit")
    #     dropdown.item(text: "Duplicate", icon: "copy", data: { action: "duplicate" })
    #     dropdown.item(text: "Archive", icon: "archive", disabled: !can_archive?)
    #     dropdown.divider
    #     dropdown.item(
    #       text: "Delete",
    #       icon: "trash",
    #       variant: :danger,
    #       data: {
    #         turbo_method: :delete,
    #         turbo_confirm: "Are you sure?"
    #       }
    #     )
    #   end
    #
    # @example Language selector dropdown
    #   render Components::Preline::Dropdown.new(
    #     trigger_text: I18n.locale.to_s.upcase,
    #     trigger_icon: "globe",
    #     placement: :"bottom-start"
    #   ) do |dropdown|
    #     I18n.available_locales.each do |locale|
    #       dropdown.item(
    #         text: t("languages.#{locale}"),
    #         href: url_for(locale: locale),
    #         active: locale == I18n.locale
    #       )
    #     end
    #   end
    #
    # @example Ellipsis menu (icon-only trigger)
    #   render Components::Preline::Dropdown.new(
    #     trigger_icon: "ellipsis-v",
    #     trigger_variant: :ghost,
    #     placement: :"bottom-end"
    #   ) do |dropdown|
    #     dropdown.item(text: "View details", icon: "info-circle")
    #     dropdown.item(text: "Download", icon: "download")
    #     dropdown.item(text: "Share", icon: "share")
    #   end
    #
    # @example Sort options dropdown
    #   render Components::Preline::Dropdown.new(
    #     trigger_text: "Sort by: #{current_sort}",
    #     trigger_icon: "sort"
    #   ) do |dropdown|
    #     dropdown.item(text: "Newest first", href: "?sort=newest", active: params[:sort] == "newest")
    #     dropdown.item(text: "Oldest first", href: "?sort=oldest", active: params[:sort] == "oldest")
    #     dropdown.item(text: "A-Z", href: "?sort=name_asc", active: params[:sort] == "name_asc")
    #     dropdown.item(text: "Z-A", href: "?sort=name_desc", active: params[:sort] == "name_desc")
    #     dropdown.item(text: "Price: Low to High", href: "?sort=price_asc", active: params[:sort] == "price_asc")
    #     dropdown.item(text: "Price: High to Low", href: "?sort=price_desc", active: params[:sort] == "price_desc")
    #   end
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
        @yielded_items = []
      end

      def view_template
        code_path 'Renders dropdown component'
        wrapper_attrs = component_attributes(additional_classes: build_wrapper_classes)

        div(**wrapper_attrs) do
          render_trigger
          render_menu do
            if block_given?
              # Try yielding interface first
              initial_items = @yielded_items.length
              content = yield(self)

              # If items were added, we're using yielding interface
              if @yielded_items.length > initial_items
                render_yielded_items
              else
                # No items added, treat as custom content
                code_path 'Renders dropdown with custom content'
                plain content if content
              end
            elsif @items.any?
              render_items
            end
          end
        end
      end

      # Add a dropdown item
      def item(text: nil, href: nil, icon: nil, divider: false, header: false, disabled: false, active: false, variant: nil, **options)
        @yielded_items << {
          text: text,
          href: href,
          icon: icon,
          divider: divider,
          header: header,
          disabled: disabled,
          active: active,
          variant: variant,
          **options
        }
      end

      # Add a divider
      # @param attrs [Hash] Additional HTML attributes for the divider
      def divider(**attrs)
        @yielded_items << { divider: true, attrs: attrs }
      end

      # Add a header
      # @param text [String] The header text
      # @param attrs [Hash] Additional HTML attributes for the header
      def header(text:, **attrs)
        @yielded_items << { header: true, text: text, attrs: attrs }
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
          divider_attrs = options[:attrs] || {}
          div(**divider_attrs, class: merge_classes('hs-dropdown-divider', divider_attrs[:class]))
        elsif header
          code_path 'Renders dropdown header'
          header_attrs = options[:attrs] || {}
          h6(**header_attrs, class: merge_classes('hs-dropdown-header', header_attrs[:class])) { text }
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

      def merge_classes(*classes)
        classes.compact.join(' ').strip.presence
      end

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

      def render_menu(&block)
        div(
          class: "hs-dropdown-menu #{@menu_class}".strip,
          aria: { labelledby: @id },
          role: 'menu',
          &block
        )
      end

      def render_items
        code_path 'Renders dropdown with items array'
        @items.each do |item|
          dropdown_item(**item)
        end
      end

      def render_yielded_items
        @yielded_items.each do |item|
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
