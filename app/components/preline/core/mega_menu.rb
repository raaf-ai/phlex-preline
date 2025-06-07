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
    # @example Basic mega menu with two columns
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
        @columns = columns
        @width = width

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
              if columns.any?
                render_columns
              elsif block_given?
                yield
              end
            end
          end
        end
      end

      private

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
    end
  end
end
