# frozen_string_literal: true

module Components
  module Preline
    # Navs component for creating navigation menus with tabs, pills, or underline styles
    # Provides a flexible navigation container with different visual variants
    #
    # @example Basic tabs navigation
    #   Navs do
    #     NavItem do
    #       NavLink(href: "/home", active: true) { "Home" }
    #     end
    #     NavItem do
    #       NavLink(href: "/about") { "About" }
    #     end
    #   end
    #
    # @example Pills style navigation
    #   Navs(variant: :pills, align: :center) do
    #     NavItem do
    #       NavLink(href: "/tab1", variant: :pills) { "Tab 1" }
    #     end
    #     NavItem do
    #       NavLink(href: "/tab2", variant: :pills, active: true) { "Tab 2" }
    #     end
    #   end
    #
    # @example Underline navigation with full width
    #   Navs(variant: :underline, fill: true) do
    #     NavItem do
    #       NavLink(href: "#", variant: :underline) { "Overview" }
    #     end
    #     NavItem do
    #       NavLink(href: "#", variant: :underline) { "Details" }
    #     end
    #   end
    class Navs < ::Components::Preline::PrelineComponent
      # @param variant [Symbol] Visual style of the navigation (:tabs, :pills, :underline)
      # @param align [Symbol] Horizontal alignment of nav items (:left, :center, :right)
      # @param fill [Boolean] Whether nav items should fill the container width
      # @param justified [Boolean] Whether nav items should be justified (equal width)
      # @param attrs [Hash] Additional HTML attributes and options
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :* Any other HTML attributes
      def initialize(variant: :tabs, align: :left, fill: false, justified: false, **attrs)
        @variant = variant
        @align = align
        @fill = fill
        @justified = justified

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        nav_attrs = component_attributes(additional_classes: [nav_classes])
        nav(**nav_attrs) do
          ul(class: list_classes) do
            yield if block_given?
          end
        end
      end

      private

      attr_reader :variant, :align, :fill, :justified

      def nav_classes
        'hs-nav'
      end

      def list_classes
        base = 'hs-nav-list flex'

        variant_class = case variant
                        when :pills then 'space-x-2'
                        when :underline then 'space-x-8 border-b border-gray-200'
                        else 'space-x-1 border-b border-gray-200' # tabs
                        end

        align_class = case align
                      when :center then 'justify-center'
                      when :right then 'justify-end'
                      else ''
                      end

        fill_class = fill ? 'w-full' : ''
        justified_class = justified ? 'justify-between w-full' : ''

        [base, variant_class, align_class, fill_class, justified_class].compact.join(' ')
      end
    end

    # NavItem component for individual navigation items
    # Wraps navigation links in list items with proper styling
    #
    # @example Basic nav item
    #   NavItem do
    #     NavLink(href: "/home") { "Home" }
    #   end
    #
    # @example Active nav item
    #   NavItem(active: true) do
    #     NavLink(href: "/current", active: true) { "Current Page" }
    #   end
    #
    # @example Disabled nav item
    #   NavItem(disabled: true) do
    #     NavLink(href: "#", disabled: true) { "Disabled" }
    #   end
    class NavItem < ::Components::Preline::PrelineComponent
      # @param active [Boolean] Whether this nav item is currently active
      # @param disabled [Boolean] Whether this nav item is disabled
      # @param attrs [Hash] Additional HTML attributes and options
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :* Any other HTML attributes
      def initialize(active: false, disabled: false, **attrs)
        @active = active
        @disabled = disabled

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        item_attrs = component_attributes(additional_classes: [item_classes])
        li(**item_attrs) do
          yield if block_given?
        end
      end

      private

      attr_reader :active, :disabled

      def item_classes
        'hs-nav-item'
      end
    end

    # NavLink component for navigation links with different visual styles
    # Provides clickable navigation elements with active and disabled states
    #
    # @example Basic tab link
    #   NavLink(href: "/home") { "Home" }
    #
    # @example Active pill link
    #   NavLink(href: "/dashboard", active: true, variant: :pills) { "Dashboard" }
    #
    # @example Disabled underline link
    #   NavLink(href: "#", disabled: true, variant: :underline) { "Disabled" }
    #
    # @example Link with custom attributes
    #   NavLink(href: "/profile", data: { turbo_frame: "main" }) { "Profile" }
    class NavLink < ::Components::Preline::PrelineComponent
      # @param href [String] URL for the navigation link
      # @param active [Boolean] Whether this link is currently active
      # @param disabled [Boolean] Whether this link is disabled
      # @param variant [Symbol] Visual style matching the parent Navs component (:tabs, :pills, :underline)
      # @param attrs [Hash] Additional HTML attributes and options
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :* Any other HTML attributes
      def initialize(href: '#', active: false, disabled: false, variant: :tabs, **attrs)
        @href = href
        @active = active
        @disabled = disabled
        @variant = variant

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        link_attrs = component_attributes(additional_classes: [link_classes])
        link_attrs[:href] = disabled ? nil : href
        link_attrs[:aria] ||= {}
        link_attrs[:aria][:current] = active ? 'page' : nil
        link_attrs[:tabindex] = disabled ? '-1' : nil

        a(**link_attrs) do
          yield if block_given?
        end
      end

      private

      attr_reader :href, :active, :disabled, :variant

      def link_classes
        base = 'hs-nav-link'

        variant_class = case variant
                        when :pills
                          'px-3 py-2 text-sm font-medium rounded-md'
                        when :underline
                          'pb-2 text-sm font-medium'
                        else # tabs
                          'px-4 py-2 text-sm font-medium rounded-t-lg'
                        end

        state_class = if disabled
                        'text-gray-400 cursor-not-allowed'
                      elsif active
                        case variant
                        when :pills then 'bg-blue-100 text-blue-700'
                        when :underline then 'text-blue-600 border-b-2 border-blue-600'
                        else 'text-blue-600 bg-white border-b-2 border-blue-600'
                        end
                      else
                        'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                      end

        [base, variant_class, state_class].compact.join(' ')
      end
    end
  end
end
