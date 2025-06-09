# frozen_string_literal: true

module Components
  module Preline
    # Offcanvas component for slide-out panels from screen edges
    #
    # @example Basic offcanvas with yielding interface
    #   render Components::Preline::Offcanvas.new(id: "sidebar") do |offcanvas|
    #     offcanvas.header(title: "Settings", close_button: true)
    #     offcanvas.body do
    #       # Settings content
    #     end
    #   end
    #
    # @example Offcanvas with nested components
    #   render Components::Preline::Offcanvas.new(id: "sidebar") do
    #     OffcanvasHeader(title: "Settings")
    #     OffcanvasBody do
    #       # Settings content
    #     end
    #   end
    #
    #   # Trigger button
    #   Button(text: "Open Settings", data: { "hs-overlay": "#sidebar" })
    #
    # @example Right-side panel without backdrop
    #   render Components::Preline::Offcanvas.new(
    #     id: "notifications",
    #     position: :right,
    #     backdrop: false,
    #     size: :lg
    #   ) do |offcanvas|
    #     offcanvas.header(title: "Notifications", close_button: true)
    #     offcanvas.body do
    #       # Notifications list
    #     end
    #   end
    #
    # @example Bottom drawer
    #   render Components::Preline::Offcanvas.new(
    #     id: "filters",
    #     position: :bottom,
    #     size: :sm
    #   ) do |offcanvas|
    #     offcanvas.header(title: "Filter Options")
    #     offcanvas.body do
    #       # Filter controls
    #     end
    #   end
    #
    # @example Admin sidebar with navigation
    #   render Components::Preline::Offcanvas.new(
    #     id: "admin-sidebar",
    #     position: :left,
    #     size: :lg
    #   ) do |offcanvas|
    #     offcanvas.header(title: "Admin Panel", close_button: false)
    #     offcanvas.body do |o|
    #       o.navigation(
    #         title: "Main Menu",
    #         items: [
    #           { text: "Dashboard", href: "/admin", icon: "home", active: true },
    #           { text: "Users", href: "/admin/users", icon: "users" },
    #           { text: "Products", href: "/admin/products", icon: "box" },
    #           { text: "Orders", href: "/admin/orders", icon: "shopping-cart" },
    #           { text: "Analytics", href: "/admin/analytics", icon: "chart-bar" }
    #         ]
    #       )
    #
    #       o.navigation(
    #         title: "Settings",
    #         items: [
    #           { text: "General", href: "/admin/settings", icon: "cog" },
    #           { text: "Security", href: "/admin/security", icon: "shield-alt" }
    #         ]
    #       )
    #     end
    #     offcanvas.footer do
    #       Button(text: "Logout", variant: :secondary, icon: "sign-out-alt", class: "w-full")
    #     end
    #   end
    #
    # @example Shopping cart offcanvas
    #   render Components::Preline::Offcanvas.new(
    #     id: "shopping-cart",
    #     position: :right,
    #     backdrop: true
    #   ) do |offcanvas|
    #     offcanvas.header(title: "Shopping Cart (#{cart.items.count})")
    #     offcanvas.body do
    #       cart.items.each do |item|
    #         div(class: "flex items-center gap-4 p-4 border-b") do
    #           img(src: item.image, class: "w-16 h-16 object-cover")
    #           div(class: "flex-1") do
    #             h4 { item.name }
    #             p(class: "text-gray-600") { "$#{item.price}" }
    #           end
    #           button(class: "text-red-500") { "Remove" }
    #         end
    #       end
    #     end
    #     offcanvas.footer(sticky: true) do
    #       div(class: "space-y-2 w-full") do
    #         div(class: "flex justify-between") do
    #           span { "Total:" }
    #           strong { "$#{cart.total}" }
    #         end
    #         Button(text: "Checkout", variant: :primary, class: "w-full")
    #       end
    #     end
    #   end
    #
    # @example Full-screen mobile menu
    #   render Components::Preline::Offcanvas.new(id: "mobile-menu") do |offcanvas|
    #     offcanvas.full_screen(padding: false)
    #     offcanvas.header(title: "Menu")
    #     offcanvas.body(class: "p-0") do
    #       nav(class: "flex flex-col") do
    #         a(href: "/", class: "px-6 py-4 hover:bg-gray-100") { "Home" }
    #         a(href: "/products", class: "px-6 py-4 hover:bg-gray-100") { "Products" }
    #         a(href: "/about", class: "px-6 py-4 hover:bg-gray-100") { "About" }
    #         a(href: "/contact", class: "px-6 py-4 hover:bg-gray-100") { "Contact" }
    #       end
    #     end
    #   end
    #
    # @example Settings panel with tabs
    #   render Components::Preline::Offcanvas.new(
    #     id: "settings",
    #     position: :right,
    #     size: :lg
    #   ) do |offcanvas|
    #     offcanvas.header(title: "Settings")
    #     offcanvas.body do
    #       Tabs.new do |tabs|
    #         tabs.tab(id: "profile", label: "Profile", active: true) do
    #           # Profile settings form
    #         end
    #         tabs.tab(id: "preferences", label: "Preferences") do
    #           # Preferences form
    #         end
    #         tabs.tab(id: "notifications", label: "Notifications") do
    #           # Notification settings
    #         end
    #       end
    #     end
    #   end
    #
    # @example Nested offcanvas trigger
    #   render Components::Preline::Offcanvas.new(id: "main-menu") do |offcanvas|
    #     offcanvas.header(title: "Main Menu")
    #     offcanvas.body do |o|
    #       # Regular menu items
    #       a(href: "/dashboard") { "Dashboard" }
    #
    #       # Trigger for nested offcanvas
    #       o.nested_trigger(
    #         text: "Advanced Settings",
    #         target_id: "advanced-settings",
    #         variant: :secondary
    #       )
    #     end
    #   end
    #
    #   # The nested offcanvas
    #   render Components::Preline::Offcanvas.new(id: "advanced-settings") do |offcanvas|
    #     offcanvas.header(title: "Advanced Settings")
    #     offcanvas.body do
    #       # Advanced settings content
    #     end
    #   end
    class Offcanvas < ::Components::Preline::PrelineComponent
      # @param id [String] Unique ID for the offcanvas element
      # @param position [Symbol] Screen edge position (:left, :right, :top, :bottom)
      # @param backdrop [Boolean] Whether to show backdrop overlay (default: true)
      # @param size [Symbol] Panel size (:sm, :default, :lg)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(id:, position: :left, backdrop: true, size: :default, **attrs)
        @id = validate_required!(id, 'id')
        @position = validate_position!(position)
        @backdrop = validate_boolean!(backdrop, 'backdrop')
        @size = validate_size!(size)
        @full_screen = false
        @full_screen_padding = true

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template(&block)
        # Backdrop
        if @backdrop
          div(
            id: "#{@id}-backdrop",
            class: 'hs-overlay-backdrop transition-opacity duration-300 fixed inset-0 bg-gray-900/50 hidden',
            data: { 'hs-overlay-backdrop': '' }
          )
        end

        # Offcanvas
        offcanvas_attrs = component_attributes(additional_classes: [offcanvas_classes])
        offcanvas_attrs[:id] = @id
        offcanvas_attrs[:data] ||= {}
        offcanvas_attrs[:data]['hs-overlay'] = ''
        offcanvas_attrs[:data]['hs-overlay-open-class'] = open_classes
        offcanvas_attrs[:data]['hs-overlay-backdrop'] = @backdrop ? 'dynamic' : 'false'
        offcanvas_attrs[:tabindex] = '-1'

        # Add bg-white for offcanvas unless full-screen
        offcanvas_attrs[:class] = [offcanvas_attrs[:class], 'bg-white'].join(' ') unless @full_screen

        div(**offcanvas_attrs) do
          if block_given?
            # Check if this is a yielding interface by checking block arity
            if block.arity == 1
              yield(self)
            else
              # Direct content pattern - yield without arguments
              yield
            end
          end
        end
      end

      # Creates a header section for the offcanvas
      #
      # @param title [String] Optional header title
      # @param close_button [Boolean] Whether to show close button
      # @param attrs [Hash] Additional HTML attributes
      def header(title: nil, close_button: true, **attrs)
        header_classes = 'flex justify-between items-center py-3 px-4 border-b'
        merged_attrs = { class: header_classes }.merge(attrs)

        div(**merged_attrs) do
          h3(class: 'font-bold text-gray-800') { title } if title

          yield if block_given?

          if close_button
            button(
              type: 'button',
              class: 'flex justify-center items-center size-7 text-sm font-semibold rounded-full border border-transparent text-gray-800 hover:bg-gray-100 disabled:opacity-50 disabled:pointer-events-none',
              data: { 'hs-overlay': '#close' }
            ) do
              span(class: 'sr-only') { 'Close' }
              svg(
                class: 'flex-shrink-0 size-4',
                width: '24',
                height: '24',
                viewBox: '0 0 24 24',
                fill: 'none',
                stroke: 'currentColor',
                stroke_width: '2',
                stroke_linecap: 'round',
                stroke_linejoin: 'round'
              ) do |s|
                s.path(d: 'M18 6 6 18')
                s.path(d: 'm6 6 12 12')
              end
            end
          end
        end
      end

      # Creates a body section for the offcanvas
      #
      # @param attrs [Hash] Additional HTML attributes
      def body(**attrs)
        body_classes = 'p-4'
        merged_attrs = { class: body_classes }.merge(attrs)

        div(**merged_attrs) do
          yield if block_given?
        end
      end

      # Creates a footer section for the offcanvas
      #
      # @param sticky [Boolean] Whether footer should be sticky at bottom
      # @param attrs [Hash] Additional HTML attributes
      def footer(sticky: true, **attrs, &block)
        footer_classes = sticky ? 'sticky bottom-0 bg-white' : ''
        base_classes = 'flex gap-x-2 py-3 px-4 border-t'
        merged_attrs = { class: [base_classes, footer_classes].join(' ').strip }.merge(attrs)

        div(**merged_attrs) do
          if block_given?
            # Pass self to allow Phlex methods in the block
            instance_eval(&block)
          end
        end
      end

      # Sets up for full-screen mode
      #
      # @param padding [Boolean] Whether to include padding
      def full_screen(padding: true)
        @size = :full
        @position = :full

        # Store for use in view_template
        @full_screen = true
        @full_screen_padding = padding
      end

      # Creates a navigation section
      #
      # @param items [Array<Hash>] Navigation items with :text, :href, :icon, :active
      # @param title [String] Optional section title
      def navigation(items:, title: nil)
        div(class: 'space-y-2') do
          h4(class: 'text-xs font-semibold uppercase text-gray-500') { title } if title

          nav(class: 'space-y-1') do
            items.each do |item|
              a(
                href: item[:href] || '#',
                class: nav_item_classes(active: item[:active])
              ) do
                i(class: "fas fa-#{item[:icon]} size-4") if item[:icon]
                span { item[:text] }
              end
            end
          end
        end
      end

      # Creates a stacked offcanvas trigger
      #
      # @param text [String] Button text
      # @param target_id [String] ID of the nested offcanvas to open
      # @param variant [Symbol] Button variant
      def nested_trigger(text:, target_id:, variant: :primary)
        button(
          type: 'button',
          class: nested_trigger_classes(variant),
          data: { 'hs-overlay': "##{target_id}" }
        ) do
          plain text
        end
      end

      private

      def offcanvas_classes
        if @full_screen
          base = 'hs-overlay hs-overlay-offcanvas fixed transition-opacity duration-300 opacity-0 hidden z-[80]'
          position_class = 'inset-0'
          size_class = ''
        else
          base = 'hs-overlay hs-overlay-offcanvas fixed transition-transform duration-300 transform hidden z-[80]'
          position_class = position_classes
          size_class = size_classes
        end

        [base, position_class, size_class].compact.join(' ').strip
      end

      def position_classes
        case @position
        when :right
          'top-0 end-0 h-full'
        when :top
          'top-0 start-0 w-full'
        when :bottom
          'bottom-0 start-0 w-full'
        else # :left
          'top-0 start-0 h-full'
        end
      end

      def size_classes
        case @position
        when :top, :bottom
          case @size
          when :sm then 'max-h-[15rem]'
          when :lg then 'max-h-[30rem]'
          else 'max-h-[25rem]'
          end
        else # :left, :right
          case @size
          when :sm then 'w-64'
          when :lg then 'w-96'
          else 'w-80'
          end
        end
      end

      def open_classes
        if @full_screen
          'opacity-100'
        else
          case @position
          when :top, :bottom then 'translate-y-0'
          else 'translate-x-0'
          end
        end
      end

      def nav_item_classes(active: false)
        base = 'flex items-center gap-x-3.5 py-2 px-2.5 text-sm rounded-lg hover:bg-gray-100'
        active_classes = active ? 'bg-gray-100 text-gray-700' : 'text-gray-700'
        [base, active_classes].join(' ')
      end

      def nested_trigger_classes(variant)
        base = 'py-2 px-3 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border'

        variant_classes = case variant
                          when :primary
                            'border-transparent bg-blue-600 text-white hover:bg-blue-700'
                          else # :secondary or any other value
                            'border-gray-200 bg-white text-gray-800 hover:bg-gray-50'
                          end

        [base, variant_classes].join(' ')
      end

      def validate_position!(position)
        valid_positions = %i[left right top bottom full]
        return position if valid_positions.include?(position)

        raise ArgumentError, "Invalid position: #{position}. Valid options are: #{valid_positions.join(', ')}"
      end

      def validate_size!(size)
        valid_sizes = %i[sm default lg full]
        return size if valid_sizes.include?(size)

        raise ArgumentError, "Invalid size: #{size}. Valid options are: #{valid_sizes.join(', ')}"
      end
    end

    # OffcanvasHeader component for offcanvas panel headers
    class OffcanvasHeader < ::Components::Preline::PrelineComponent
      # @param title [String] Optional header title
      # @param close_button [Boolean] Whether to show close button (default: true)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(title: nil, close_button: true, **attrs)
        @title = title
        @close_button = close_button

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        header_attrs = component_attributes(additional_classes: [header_classes])
        div(**header_attrs) do
          h3(class: 'font-bold text-gray-800') { @title } if @title

          yield if block_given?

          if @close_button
            button(
              type: 'button',
              class: close_button_classes,
              data: { 'hs-overlay': '#close' }
            ) do
              span(class: 'sr-only') { 'Close' }
              svg(
                class: 'flex-shrink-0 size-4',
                width: '24',
                height: '24',
                viewBox: '0 0 24 24',
                fill: 'none',
                stroke: 'currentColor',
                stroke_width: '2',
                stroke_linecap: 'round',
                stroke_linejoin: 'round'
              ) do |s|
                s.path(d: 'M18 6 6 18')
                s.path(d: 'm6 6 12 12')
              end
            end
          end
        end
      end

      private

      def header_classes
        'flex justify-between items-center py-3 px-4 border-b'
      end

      def close_button_classes
        'flex justify-center items-center size-7 text-sm font-semibold rounded-full border border-transparent text-gray-800 hover:bg-gray-100 disabled:opacity-50 disabled:pointer-events-none'
      end
    end

    # OffcanvasBody component for offcanvas panel content
    class OffcanvasBody < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        body_attrs = component_attributes(additional_classes: [body_classes])
        div(**body_attrs) do
          yield if block_given?
        end
      end

      private

      def body_classes
        'p-4'
      end
    end
  end
end
