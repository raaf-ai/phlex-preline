# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI navbar component for site navigation.
    # Supports responsive behavior, dropdowns, branding, and fixed positioning.
    #
    # @example Basic navbar with brand and items
    #   render Components::Preline::Navbar.new(
    #     brand: { text: "My App", href: "/" },
    #     items: [
    #       { text: "Home", href: "/", active: true },
    #       { text: "About", href: "/about" },
    #       { text: "Contact", href: "/contact" }
    #     ]
    #   )
    #
    # @example Navbar with dropdown and icons
    #   render Components::Preline::Navbar.new(
    #     brand: { text: "App", logo: "/logo.png" },
    #     variant: :dark,
    #     fixed: :top,
    #     items: [
    #       { text: "Dashboard", href: "/dashboard", icon: "home" },
    #       {
    #         text: "Products",
    #         dropdown: true,
    #         dropdown_items: [
    #           { text: "All Products", href: "/products" },
    #           { divider: true },
    #           { text: "Add New", href: "/products/new", icon: "plus" }
    #         ]
    #       }
    #     ]
    #   )
    class Navbar < ::Components::Preline::PrelineComponent
      # Initialize a new Navbar component
      #
      # @param brand [String, Hash, nil] Brand text or hash with :text, :href, :logo
      # @param items [Array<Hash>] Navigation items with :text, :href, :active, :dropdown, :icon, :badge
      # @param variant [Symbol] Color variant (:light, :dark)
      # @param fixed [Symbol, nil] Fixed position (:top, :bottom)
      # @param expand [Symbol] Responsive breakpoint for expansion (:sm, :md, :lg, :xl)
      # @param container [Boolean] Wrap content in container
      # @param class [String] Additional CSS classes for navbar
      # @param brand_class [String] Additional CSS classes for brand
      # @param nav_class [String] Additional CSS classes for nav list
      # @param id [String, nil] Unique ID for collapse functionality
      def initialize(
        brand: nil,
        items: [],
        variant: :light,
        fixed: nil,
        expand: :lg,
        container: true,
        brand_class: '',
        nav_class: '',
        id: nil,
        **attrs
      )
        @brand = brand
        @items = items
        @variant = variant
        @fixed = fixed
        @expand = expand
        @container = container
        @custom_class = attrs.delete(:class)
        @brand_class = brand_class
        @nav_class = nav_class
        @id = id || "navbar-#{SecureRandom.hex(4)}"
      end

      def view_template(&block)
        code_path('navbar:view_template:start')
        nav(
          class: build_navbar_classes,
          data: { 'hs-navbar': true }
        ) do
          wrapper_tag do
            if @brand
              code_path('navbar:rendering_brand')
              render_brand
            end
            render_toggler
            render_collapse(&block)
          end
        end
      end

      # Create a navigation item within the navbar
      #
      # @param text [String, nil] Item text
      # @param href [String, nil] Item link URL
      # @param active [Boolean] Mark item as active
      # @param dropdown [Boolean] Enable dropdown menu
      # @param dropdown_items [Array<Hash>] Dropdown menu items
      # @param icon [String, nil] FontAwesome icon name
      # @param badge [String, Hash, nil] Badge content or badge component props
      # @param options [Hash] Additional HTML attributes
      # @yield Block for custom content
      def nav_item(
        text: nil,
        href: nil,
        active: false,
        dropdown: false,
        dropdown_items: [],
        icon: nil,
        badge: nil,
        **options
      )
        li(class: "hs-nav-item #{'hs-dropdown' if dropdown} #{'hs-active' if active}") do
          if dropdown
            code_path('navbar:rendering_dropdown_item')
            render_dropdown_toggle(text, icon, badge)
            render_dropdown_menu(dropdown_items)
          elsif block_given?
            yield
          else
            code_path('navbar:rendering_regular_item')
            render_nav_link(text, href, active, icon, badge, options)
          end
        end
      end

      private

      def build_navbar_classes
        classes = ['hs-navbar']
        code_path("navbar:variant_#{@variant}")
        classes << "hs-navbar-#{@variant}"
        classes << "hs-navbar-expand-#{@expand}" if @expand
        if @fixed
          code_path("navbar:fixed_position_#{@fixed}")
          classes << "hs-navbar-fixed-#{@fixed}"
        end
        classes << @custom_class
        classes.join(' ').strip
      end

      def wrapper_tag(&block)
        if @container
          code_path('navbar:container_enabled')
          div(class: 'hs-container', &block)
        else
          code_path('navbar:container_disabled')
          yield
        end
      end

      def render_brand
        if @brand.is_a?(Hash)
          code_path('navbar:brand_is_hash')
          a(href: @brand[:href] || '#', class: "hs-navbar-brand #{@brand_class}".strip) do
            if @brand[:logo]
              code_path('navbar:brand_has_logo')
              img(
                src: @brand[:logo],
                alt: @brand[:text] || 'Logo',
                class: 'hs-navbar-brand-logo'
              )
            end

            span(class: 'hs-navbar-brand-text') { @brand[:text] } if @brand[:text]
          end
        else
          code_path('navbar:brand_is_string')
          a(href: '#', class: "hs-navbar-brand #{@brand_class}".strip) do
            plain @brand
          end
        end
      end

      def render_toggler
        button(
          class: 'hs-navbar-toggler',
          type: 'button',
          data: {
            'hs-collapse-toggle': "##{@id}",
            'hs-navbar-toggler': true
          },
          aria: {
            controls: @id,
            expanded: 'false',
            label: 'Toggle navigation'
          }
        ) do
          span(class: 'hs-navbar-toggler-icon')
        end
      end

      def render_collapse
        div(
          id: @id,
          class: 'hs-navbar-collapse'
        ) do
          if block_given?
            yield
          else
            render_nav_items
          end
        end
      end

      def render_nav_items
        ul(class: "hs-navbar-nav #{@nav_class}".strip) do
          @items.each do |item|
            nav_item(**item)
          end
        end
      end

      def render_nav_link(text, href, active, icon, badge, options)
        code_path('navbar:nav_link_active') if active
        a(
          href: href || '#',
          class: "hs-nav-link #{'hs-active' if active}",
          **options
        ) do
          if icon
            code_path('navbar:nav_link_with_icon')
            i(class: "fas fa-#{icon} hs-nav-icon")
          end

          span { text } if text

          if badge
            code_path('navbar:nav_link_with_badge')
            span(class: 'hs-nav-badge ml-2') do
              if badge.is_a?(Hash)
                # Support both :text and :label keys for badge text
                badge_text = badge[:text] || badge[:label] || ''
                render Badge.new(text: badge_text, **badge.except(:text, :label))
              else
                plain badge.to_s
              end
            end
          end
        end
      end

      def render_dropdown_toggle(text, icon, badge)
        button(
          class: 'hs-nav-link hs-dropdown-toggle',
          type: 'button',
          data: { 'hs-dropdown-toggle': true },
          aria: {
            haspopup: 'true',
            expanded: 'false'
          }
        ) do
          if icon
            code_path('navbar:dropdown_toggle_with_icon')
            i(class: "fas fa-#{icon} hs-nav-icon")
          end

          span { text } if text

          if badge
            code_path('navbar:dropdown_toggle_with_badge')
            span(class: 'hs-nav-badge ml-2') do
              if badge.is_a?(Hash)
                # Support both :text and :label keys for badge text
                badge_text = badge[:text] || badge[:label] || ''
                render Badge.new(text: badge_text, **badge.except(:text, :label))
              else
                plain badge.to_s
              end
            end
          end

          i(class: 'fas fa-chevron-down hs-dropdown-icon ml-1')
        end
      end

      def render_dropdown_menu(items)
        div(class: 'hs-dropdown-menu', role: 'menu') do
          items.each do |item|
            if item[:divider]
              code_path('navbar:dropdown_item_divider')
              div(class: 'hs-dropdown-divider')
            elsif item[:header]
              code_path('navbar:dropdown_item_header')
              h6(class: 'hs-dropdown-header') { item[:text] }
            else
              code_path('navbar:dropdown_item_with_icon') if item[:icon]
              code_path('navbar:dropdown_item_active') if item[:active]
              a(
                href: item[:href] || '#',
                class: "hs-dropdown-item #{'hs-active' if item[:active]}",
                role: 'menuitem'
              ) do
                i(class: "fas fa-#{item[:icon]} mr-2") if item[:icon]
                plain item[:text]
              end
            end
          end
        end
      end
    end
  end
end
