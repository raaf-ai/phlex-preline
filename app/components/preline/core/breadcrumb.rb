# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI breadcrumb component for hierarchical navigation.
    # Shows the current page location within a navigational hierarchy.
    #
    # @example Basic breadcrumb with yielding interface
    #   render Components::Preline::Breadcrumb.new do |breadcrumb|
    #     breadcrumb.item(text: "Home", href: "/")
    #     breadcrumb.item(text: "Products", href: "/products")
    #     breadcrumb.item(text: "Electronics", href: "/products/electronics")
    #     breadcrumb.item(text: "Laptop")  # Current page (no href)
    #   end
    #
    # @example Breadcrumb with icons and custom separator
    #   render Components::Preline::Breadcrumb.new(separator: :chevron) do |breadcrumb|
    #     breadcrumb.item(text: "Dashboard", href: "/", icon: "home")
    #     breadcrumb.item(text: "Settings", href: "/settings", icon: "cog")
    #     breadcrumb.item(text: "Profile")
    #   end
    #
    # @example Basic breadcrumb with items array
    #   render Components::Preline::Breadcrumb.new(
    #     items: [
    #       { text: "Home", href: "/" },
    #       { text: "Products", href: "/products" },
    #       { text: "Electronics", href: "/products/electronics" },
    #       { text: "Laptop" }  # Current page (no href)
    #     ]
    #   )
    #
    # @example Using convenience methods
    #   render Components::Preline::Breadcrumb.new do |breadcrumb|
    #     breadcrumb.home  # Adds home with default icon
    #     breadcrumb.items(
    #       { text: "Products", href: "/products" },
    #       { text: "Electronics", href: "/products/electronics" }
    #     )
    #     breadcrumb.item(text: "Laptop")
    #   end
    #
    # @example Auto-generating from URL path
    #   render Components::Preline::Breadcrumb.new do |breadcrumb|
    #     breadcrumb.from_path(
    #       "/products/electronics/laptops",
    #       labels: {
    #         "products" => "All Products",
    #         "electronics" => "Electronic Devices"
    #       }
    #     )
    #   end
    #
    # @example E-commerce breadcrumb with custom styling
    #   render Components::Preline::Breadcrumb.new(
    #     separator: :chevron,
    #     class: "text-sm text-gray-600",
    #     item_class: "hover:text-blue-600"
    #   ) do |breadcrumb|
    #     breadcrumb.home(text: "Shop", icon: "shopping-cart")
    #     breadcrumb.item(text: "Women's Fashion", href: "/women")
    #     breadcrumb.item(text: "Dresses", href: "/women/dresses")
    #     breadcrumb.item(text: "Summer Collection")
    #   end
    #
    # @example Admin dashboard breadcrumb
    #   render Components::Preline::Breadcrumb.new(separator: :arrow) do |breadcrumb|
    #     breadcrumb.home(text: "Admin", href: "/admin", icon: "cog")
    #     breadcrumb.item(text: "Users", href: "/admin/users", icon: "users")
    #     breadcrumb.item(text: "John Doe", href: "/admin/users/123")
    #     breadcrumb.item(text: "Edit Profile")
    #   end
    #
    # @example Dynamic breadcrumb from current route
    #   render Components::Preline::Breadcrumb.new do |breadcrumb|
    #     # Assuming request.path = "/blog/2024/03/my-article"
    #     breadcrumb.from_path(request.path, labels: {
    #       "blog" => "Blog Posts",
    #       "2024" => "Year 2024",
    #       "03" => "March",
    #       "my-article" => "How to Build Better UIs"
    #     })
    #   end
    #
    # @example Clearing and rebuilding breadcrumbs
    #   render Components::Preline::Breadcrumb.new do |breadcrumb|
    #     breadcrumb.home
    #     breadcrumb.item(text: "Products", href: "/products")
    #
    #     # Clear and rebuild based on condition
    #     if current_user.admin?
    #       breadcrumb.clear
    #       breadcrumb.home(text: "Admin", href: "/admin")
    #       breadcrumb.item(text: "Product Management", href: "/admin/products")
    #     end
    #
    #     breadcrumb.item(text: "Edit Product")
    #   end
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
        @items = validate_array!(items, 'items')
        @separator = validate_separator!(separator)
        @item_class = item_class
        @yielded_items = []

        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders breadcrumb component'
        nav(aria: { label: 'Breadcrumb' }) do
          ol(**component_attributes(additional_classes: ['hs-breadcrumb'])) do
            if block_given?
              yield(self)
              # Always render yielded items if we have any, regardless of whether they were added before or after yield
              render_yielded_items if @yielded_items.any?
            elsif @items.any?
              render_items
            end
          end
        end
      end

      # Adds a breadcrumb item
      #
      # @param text [String] The display text for the breadcrumb item
      # @param href [String, nil] The URL for the item (nil for current page)
      # @param icon [String, nil] FontAwesome icon name to display before text
      # @param attrs [Hash] Additional HTML attributes for the item
      def item(text:, href: nil, icon: nil, **attrs)
        @yielded_items << { text: text, href: href, icon: icon, attrs: attrs }
      end

      # Adds a home breadcrumb item
      #
      # @param text [String] The display text (default: "Home")
      # @param href [String] The URL for home (default: "/")
      # @param icon [String, nil] FontAwesome icon name (default: "home")
      # @param attrs [Hash] Additional HTML attributes for the item
      def home(text: 'Home', href: '/', icon: 'home', **attrs)
        item(text: text, href: href, icon: icon, **attrs)
      end

      # Adds multiple breadcrumb items at once
      #
      # @param items [Array<Hash>] Array of item hashes with :text, :href, and optional :icon keys
      def items(*items)
        items.each do |item_data|
          item(**item_data)
        end
      end

      # Generates breadcrumb items from a path
      #
      # @param path [String] URL path to convert to breadcrumbs (e.g., "/products/electronics/laptops")
      # @param labels [Hash] Custom labels for path segments (e.g., { "products" => "All Products" })
      def from_path(path, labels: {})
        segments = path.split('/').reject(&:empty?)

        # Add home
        home

        # Add each segment
        segments.each_with_index do |segment, index|
          href = "/#{segments[0..index].join('/')}"
          label = labels[segment] || segment.split(/[-_]/).map(&:capitalize).join(' ')
          is_last = index == segments.length - 1

          item(text: label, href: is_last ? nil : href)
        end
      end

      # Clears all yielded items
      def clear
        @yielded_items.clear
      end

      private

      def render_items
        @items.each_with_index do |item, index|
          is_last = index == @items.length - 1
          render_item(item, is_last)
        end
      end

      def render_yielded_items
        @yielded_items.each_with_index do |item, index|
          is_last = index == @yielded_items.length - 1
          render_item(item, is_last)
        end
      end

      def render_item(item, is_last)
        li_attrs = extract_and_merge_attrs(item[:attrs], class: build_item_classes(is_last, item[:attrs]&.dig(:class)))
        li(**li_attrs) do
          if is_last || !item[:href]
            render_active_item(item)
          else
            render_link_item(item)
          end

          render_separator unless is_last
        end
      end

      def render_link_item(item)
        # Extract attributes but keep href and merge classes
        link_attrs = extract_and_merge_attrs(
          item[:attrs],
          href: item[:href],
          class: merge_classes('hs-breadcrumb-link', item[:attrs]&.dig(:class))
        )

        a(**link_attrs) do
          render_item_content(item)
        end
      end

      def render_active_item(item)
        # Extract attributes and merge with defaults
        span_attrs = extract_and_merge_attrs(
          item[:attrs],
          class: merge_classes('hs-breadcrumb-active', item[:attrs]&.dig(:class)),
          aria: { current: 'page' }
        )

        span(**span_attrs) do
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

      def build_item_classes(is_last, additional_class = nil)
        classes = ['hs-breadcrumb-item']
        classes << 'hs-breadcrumb-item-active' if is_last
        classes << @item_class if @item_class.present?
        classes << additional_class if additional_class.present?
        classes.compact.join(' ').strip
      end

      def extract_and_merge_attrs(attrs, defaults = {})
        return defaults if attrs.nil?

        # Remove class from attrs since we handle it separately
        extracted_attrs = attrs.except(:class)

        # Merge with defaults
        defaults.merge(extracted_attrs)
      end

      def merge_classes(*classes)
        classes.compact.join(' ').strip.presence
      end

      def validate_separator!(separator)
        valid_separators = ['/', '>', '-', '|', :chevron, :arrow]
        return separator if valid_separators.include?(separator)

        raise ArgumentError, "Invalid separator: #{separator}. Valid options are: #{valid_separators.join(', ')}"
      end

      def validate_array!(array, name)
        return array if array.is_a?(Array)

        raise ArgumentError, "#{name} must be an array, got #{array.class}"
      end
    end
  end
end
