# frozen_string_literal: true

module Components
  module Preline
    # MegaMenu component for creating complex dropdown menus with multiple columns
    #
    # The MegaMenu component provides a sophisticated dropdown interface that can display
    # content in multiple columns, making it ideal for navigation menus with many options,
    # site maps, or grouped content. It supports customizable widths, column layouts,
    # and rich content including icons, descriptions, and badges.
    #
    # @example Basic mega menu with yielding interface
    #   render Components::Preline::MegaMenu.new(trigger_text: "Products") do |menu|
    #     menu.column(title: "Software") do |col|
    #       col.item(title: "CRM", href: "/products/crm", icon: "users")
    #       col.item(title: "Analytics", href: "/products/analytics", icon: "chart-bar")
    #     end
    #     menu.column(title: "Services") do |col|
    #       col.item(title: "Consulting", href: "/services/consulting", description: "Expert guidance")
    #       col.item(title: "Support", href: "/services/support", badge: "New")
    #     end
    #   end
    #
    # @example Mega menu with columns array
    #   MegaMenu(
    #     trigger_text: "Products",
    #     columns: [
    #       {
    #         title: "Software",
    #         items: [
    #           { title: "CRM", href: "/products/crm", icon: "users" },
    #           { title: "Analytics", href: "/products/analytics", icon: "chart-bar" }
    #         ]
    #       },
    #       {
    #         title: "Services",
    #         items: [
    #           { title: "Consulting", href: "/services/consulting", description: "Expert guidance" },
    #           { title: "Support", href: "/services/support", badge: "New" }
    #         ]
    #       }
    #     ]
    #   )
    #
    # @example Full-width mega menu with custom content
    #   MegaMenu(trigger_text: "Resources", width: :full) do
    #     div(class: "grid grid-cols-3 gap-6") do
    #       # Column 1: Links
    #       div do
    #         h3(class: "font-semibold mb-3") { "Documentation" }
    #         # Custom link list
    #       end
    #
    #       # Column 2: Featured content
    #       div do
    #         Card do
    #           h4 { "Getting Started Guide" }
    #           p { "Learn the basics..." }
    #         end
    #       end
    #
    #       # Column 3: Call to action
    #       div do
    #         Button(variant: :primary) { "Start Free Trial" }
    #       end
    #     end
    #   end
    #
    # @example E-commerce mega menu with categories
    #   render Components::Preline::MegaMenu.new(trigger_text: "Shop", width: :xl) do |menu|
    #     menu.column(title: "Men's Fashion") do |col|
    #       col.item(title: "T-Shirts", href: "/men/tshirts")
    #       col.item(title: "Shirts", href: "/men/shirts")
    #       col.item(title: "Jeans", href: "/men/jeans")
    #       col.item(title: "Shoes", href: "/men/shoes", badge: "Sale")
    #     end
    #
    #     menu.column(title: "Women's Fashion") do |col|
    #       col.item(title: "Dresses", href: "/women/dresses")
    #       col.item(title: "Tops", href: "/women/tops")
    #       col.item(title: "Accessories", href: "/women/accessories", badge: "New")
    #       col.item(title: "Shoes", href: "/women/shoes")
    #     end
    #
    #     menu.column(title: "Featured") do |col|
    #       col.item(
    #         title: "Summer Collection",
    #         href: "/featured/summer",
    #         description: "Get 30% off on all summer items"
    #       )
    #       col.item(
    #         title: "New Arrivals",
    #         href: "/new",
    #         description: "Check out the latest trends"
    #       )
    #     end
    #   end
    #
    # @example Tech company mega menu with resources
    #   render Components::Preline::MegaMenu.new(
    #     trigger_text: "Resources",
    #     trigger_icon: "book",
    #     width: :full
    #   ) do |menu|
    #     menu.column(title: "Learn") do |col|
    #       col.item(title: "Documentation", href: "/docs", icon: "book-open")
    #       col.item(title: "Tutorials", href: "/tutorials", icon: "graduation-cap")
    #       col.item(title: "API Reference", href: "/api", icon: "code")
    #       col.item(title: "Examples", href: "/examples", icon: "flask")
    #     end
    #
    #     menu.column(title: "Community") do |col|
    #       col.item(title: "Forum", href: "/forum", icon: "comments")
    #       col.item(title: "Discord", href: "/discord", icon: "discord", badge: "Join")
    #       col.item(title: "GitHub", href: "/github", icon: "github")
    #       col.item(title: "Stack Overflow", href: "/stackoverflow", icon: "stack-overflow")
    #     end
    #
    #     menu.column(title: "Company") do |col|
    #       col.item(title: "About Us", href: "/about", icon: "building")
    #       col.item(title: "Blog", href: "/blog", icon: "newspaper")
    #       col.item(title: "Careers", href: "/careers", icon: "briefcase", badge: "Hiring")
    #       col.item(title: "Contact", href: "/contact", icon: "envelope")
    #     end
    #   end
    #
    # @example Service platform mega menu
    #   render Components::Preline::MegaMenu.new(trigger_text: "Services") do |menu|
    #     menu.column(title: "Development") do |col|
    #       col.item(
    #         title: "Web Development",
    #         href: "/services/web",
    #         description: "Custom websites and web applications"
    #       )
    #       col.item(
    #         title: "Mobile Apps",
    #         href: "/services/mobile",
    #         description: "iOS and Android development"
    #       )
    #     end
    #
    #     menu.column(title: "Design") do |col|
    #       col.item(
    #         title: "UI/UX Design",
    #         href: "/services/design",
    #         description: "User-centered design solutions"
    #       )
    #       col.item(
    #         title: "Branding",
    #         href: "/services/branding",
    #         description: "Logo and identity design"
    #       )
    #     end
    #   end
    #
    # @example Mega menu with mixed column content
    #   MegaMenu(
    #     trigger_text: "Company",
    #     width: :lg,
    #     columns: [
    #       {
    #         title: "About",
    #         items: [
    #           { title: "Our Story", href: "/about" },
    #           { title: "Team", href: "/team" },
    #           { title: "Careers", href: "/careers", badge: "Hiring" }
    #         ]
    #       },
    #       {
    #         title: "Connect",
    #         content: -> do
    #           div(class: "space-y-3") do
    #             p(class: "text-sm text-gray-600") { "Follow us" }
    #             div(class: "flex gap-3") do
    #               a(href: "#", class: "text-gray-400 hover:text-gray-600") do
    #                 i(class: "fab fa-twitter")
    #               end
    #               a(href: "#", class: "text-gray-400 hover:text-gray-600") do
    #                 i(class: "fab fa-linkedin")
    #               end
    #             end
    #           end
    #         end
    #       }
    #     ]
    #   )
    class MegaMenu < ::Components::Preline::PrelineComponent
      # @param trigger_text [String] Text displayed on the trigger button
      # @param columns [Array<Hash>] Array of column configurations
      # @option columns [String] :title Title for the column
      # @option columns [Array<Hash>] :items Array of menu items
      # @option columns [String, Proc] :content Custom content for the column
      # @param width [Symbol] Width of the mega menu (:auto, :md, :lg, :xl, :full)
      # @param attrs [Hash] Additional HTML attributes for the container
      def initialize(trigger_text:, columns: [], width: :auto, **attrs)
        @trigger_text = validate_required!(trigger_text, 'trigger_text')
        @columns = validate_columns!(columns)
        @width = validate_width!(width)
        @yielded_columns = []

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        mega_menu_attrs = component_attributes(additional_classes: %w[hs-mega-menu relative])
        mega_menu_attrs[:data] ||= {}
        mega_menu_attrs[:data]['hs-mega-menu'] = ''

        div(**mega_menu_attrs) do
          # Trigger button
          button(
            type: 'button',
            class: trigger_classes,
            data: { 'hs-mega-menu-toggle': '' }
          ) do
            plain trigger_text
            render_chevron_icon
          end

          # Mega menu content
          div(
            class: menu_classes,
            data: { 'hs-mega-menu-content': '' }
          ) do
            div(class: 'p-6') do
              if block_given?
                # Try yielding interface first
                initial_columns = @yielded_columns.length
                yield(self)

                if @yielded_columns.length > initial_columns
                  # We're using the yielding interface
                  render_yielded_columns
                elsif columns.any?
                  # No yielded columns but we have columns array
                  render_columns
                end
                # If no columns were yielded and no columns array, content was rendered by yield
              elsif columns.any?
                render_columns
              end
            end
          end
        end
      end

      # Creates a column in the mega menu
      #
      # @param title [String] The title for the column
      # @param attrs [Hash] Additional attributes for the column
      def column(title: nil, **attrs, &_block)
        column_data = {
          title: title,
          items: [],
          content: nil
        }.merge(attrs)

        if block_given?
          interface = MegaMenuColumnInterface.new(column_data[:items])
          yield(interface)
        end

        @yielded_columns << column_data
      end

      # Creates a two-column layout
      #
      # @param left_title [String] Title for left column
      # @param right_title [String] Title for right column
      def two_column_layout(left_title:, right_title:)
        column(title: left_title) do |col|
          yield(col, :left) if block_given?
        end
        column(title: right_title) do |col|
          yield(col, :right) if block_given?
        end
      end

      # Creates a three-column layout
      #
      # @param titles [Array<String>] Titles for the three columns
      def three_column_layout(titles:)
        titles.each_with_index do |title, index|
          column(title: title) do |col|
            yield(col, index) if block_given?
          end
        end
      end

      # Creates a featured section column
      #
      # @param title [String] Section title
      # @param description [String] Section description
      # @param cta_text [String] Call-to-action button text
      # @param cta_href [String] Call-to-action URL
      def featured_section(title:, description: nil, cta_text: nil, cta_href: nil, &block)
        column_data = {
          title: nil,
          items: [],
          content: lambda do
            div(class: 'space-y-3') do
              h4(class: 'text-lg font-semibold text-gray-900') { title }
              p(class: 'text-sm text-gray-600') { description } if description

              if cta_text && cta_href
                a(
                  href: cta_href,
                  class: 'inline-flex items-center gap-x-2 text-sm font-semibold text-blue-600 hover:text-blue-800'
                ) do
                  plain cta_text
                  svg(
                    class: 'size-2.5',
                    width: '16',
                    height: '16',
                    viewBox: '0 0 16 16',
                    fill: 'none'
                  ) do |s|
                    s.path(
                      d: 'M5.27921 2L10.9257 7.64645C11.1209 7.84171 11.1209 8.15829 10.9257 8.35355L5.27921 14',
                      stroke: 'currentColor',
                      stroke_width: '2',
                      stroke_linecap: 'round'
                    )
                  end
                end
              end

              instance_eval(&block) if block_given?
            end
          end
        }

        @yielded_columns << column_data
      end

      # Creates a footer section with links or CTAs
      #
      # @param content [Proc] Custom footer content
      def footer_section(&block)
        column_data = {
          title: nil,
          items: [],
          content: lambda do
            div(class: 'pt-3 mt-3 border-t border-gray-200') do
              instance_eval(&block) if block_given?
            end
          end
        }

        @yielded_columns << column_data
      end

      # Creates a product showcase column
      #
      # @param products [Array<Hash>] Array of product hashes with :name, :price, :image, :href
      def product_showcase(products:)
        column_data = {
          title: nil,
          items: [],
          content: lambda do
            div(class: 'grid gap-3') do
              products.each do |product|
                a(
                  href: product[:href] || '#',
                  class: 'flex gap-x-3 hover:bg-gray-50 rounded-lg p-2'
                ) do
                  if product[:image]
                    img(
                      src: product[:image],
                      alt: product[:name],
                      class: 'size-16 rounded-lg object-cover'
                    )
                  end
                  div(class: 'grow') do
                    p(class: 'font-medium text-gray-800') { product[:name] }
                    p(class: 'text-sm text-gray-600') { product[:price] } if product[:price]
                  end
                end
              end
            end
          end
        }

        @yielded_columns << column_data
      end

      private

      def render_yielded_columns
        div(class: "grid gap-6 #{yielded_grid_classes}") do
          @yielded_columns.each do |column|
            render_column(column)
          end
        end
      end

      def yielded_grid_classes
        cols = @yielded_columns.size
        case cols
        when 1 then 'grid-cols-1'
        when 2 then 'grid-cols-2'
        when 3 then 'grid-cols-3'
        when 4 then 'grid-cols-4'
        else "grid-cols-#{[cols, 5].min}"
        end
      end

      def trigger_classes
        'hs-mega-menu-toggle py-2 px-3 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-gray-200 bg-white text-gray-800 shadow-sm hover:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none'
      end

      def menu_classes
        base = 'hs-mega-menu-content hidden absolute z-10 bg-white shadow-md rounded-lg'

        width_class = case width
                      when :full then 'left-0 right-0'
                      when :xl then 'w-[48rem]'
                      when :lg then 'w-[36rem]'
                      when :md then 'w-[24rem]'
                      else 'w-auto min-w-[15rem]'
                      end

        [base, width_class].compact.join(' ')
      end

      def render_columns
        div(class: "grid gap-6 #{grid_classes}") do
          columns.each do |column|
            render_column(column)
          end
        end
      end

      def grid_classes
        cols = columns.size
        case cols
        when 1 then 'grid-cols-1'
        when 2 then 'grid-cols-2'
        when 3 then 'grid-cols-3'
        when 4 then 'grid-cols-4'
        else "grid-cols-#{[cols, 5].min}"
        end
      end

      def render_column(column)
        div(class: 'space-y-3') do
          h3(class: 'font-semibold text-gray-800') { column[:title] } if column[:title]

          if column[:items]
            ul(class: 'space-y-1.5') do
              column[:items].each do |item|
                render_column_item(item)
              end
            end
          end

          if column[:content]
            if column[:content].is_a?(String)
              div { column[:content] }
            else
              column[:content].call
            end
          end
        end
      end

      def render_column_item(item)
        li do
          a(
            href: item[:href] || '#',
            class: 'flex items-start gap-x-3 text-sm text-gray-800 hover:text-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 p-2 hover:bg-gray-100'
          ) do
            if item[:icon]
              div(class: 'mt-0.5 flex-shrink-0') do
                i(class: "fas fa-#{item[:icon]} text-gray-400")
              end
            end

            div(class: 'grow') do
              span(class: 'block font-medium') { item[:title] }
              p(class: 'text-sm text-gray-600 mt-1') { item[:description] } if item[:description]
              if item[:badge]
                span(class: 'inline-flex items-center gap-x-1.5 py-0.5 px-2 rounded-full text-xs font-medium bg-blue-100 text-blue-800 mt-1') do
                  item[:badge]
                end
              end
            end
          end
        end
      end

      def render_chevron_icon
        svg(
          class: 'hs-mega-menu-open:rotate-180 size-4 transition duration-300',
          xmlns: 'http://www.w3.org/2000/svg',
          width: '24',
          height: '24',
          viewBox: '0 0 24 24',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          stroke_linecap: 'round',
          stroke_linejoin: 'round'
        ) do |s|
          s.path(d: 'm6 9 6 6 6-6')
        end
      end

      attr_reader :trigger_text, :columns, :width

      def validate_columns!(columns)
        return columns if columns.is_a?(Array)

        raise ArgumentError, "columns must be an array, got #{columns.class}"
      end

      def validate_width!(width)
        valid_widths = %i[auto sm md lg xl full]
        return width if valid_widths.include?(width)

        raise ArgumentError, "Invalid width: #{width}. Valid options are: #{valid_widths.join(', ')}"
      end
    end

    # Interface class for mega menu columns
    class MegaMenuColumnInterface
      def initialize(items_array)
        @items = items_array
      end

      # Adds an item to the column
      #
      # @param title [String] The title of the item
      # @param href [String] The URL for the item
      # @param description [String, nil] Optional description text
      # @param icon [String, nil] FontAwesome icon name
      # @param badge [String, nil] Badge text to display
      # @param attrs [Hash] Additional attributes
      def item(title:, href: '#', description: nil, icon: nil, badge: nil, **attrs)
        @items << {
          title: title,
          href: href,
          description: description,
          icon: icon,
          badge: badge
        }.merge(attrs)
      end
    end
  end
end
