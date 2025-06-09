# frozen_string_literal: true

module Components
  module Preline
    # Sidebar component for navigation panels
    #
    # @example Basic sidebar with yielding interface
    #   render Components::Preline::Sidebar.new do |sidebar|
    #     sidebar.menu do |menu|
    #       menu.item(href: "/", active: true) { "Dashboard" }
    #       menu.item(href: "/users") { "Users" }
    #       menu.item(href: "/settings", badge: "New") { "Settings" }
    #     end
    #   end
    #
    # @example Sidebar with nested components
    #   render Components::Preline::Sidebar.new do
    #     SidebarMenu do
    #       SidebarMenuItem(href: "/", active: true) { "Dashboard" }
    #       SidebarMenuItem(href: "/users") { "Users" }
    #       SidebarMenuItem(href: "/settings", badge: "New") { "Settings" }
    #     end
    #   end
    #
    # @example With logo and sections
    #   render Components::Preline::Sidebar.new(
    #     logo: -> { img(src: "/logo.png", alt: "Logo", class: "h-8") }
    #   ) do
    #     SidebarMenu do
    #       div(class: "text-xs font-semibold text-gray-400 uppercase") { "Main" }
    #       SidebarMenuItem(href: "/", icon: icon("home"), active: true) { "Home" }
    #       SidebarMenuItem(href: "/projects", icon: icon("folder")) { "Projects" }
    #
    #       div(class: "text-xs font-semibold text-gray-400 uppercase mt-4") { "Admin" }
    #       SidebarMenuItem(href: "/users", icon: icon("users")) { "Users" }
    #       SidebarMenuItem(href: "/settings", icon: icon("cog")) { "Settings" }
    #     end
    #   end
    class Sidebar < ::Components::Preline::PrelineComponent
      # @param id [String] Optional sidebar ID (auto-generated if not provided)
      # @param logo [Proc] Optional logo content block
      # @param attrs [Hash] Additional HTML attributes
      def initialize(id: nil, logo: nil, **attrs)
        @id = id || "sidebar-#{SecureRandom.hex(4)}"
        @logo = logo

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:data, :aria, :role)
        @html_attrs[:id] = @id
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template(&block)
        code_path 'Renders sidebar component'
        nav(
          **@html_attrs.except(:data),
          **@options,
          class: sidebar_classes,
          data: { 'hs-sidebar': '' }.merge(@html_attrs[:data] || {})
        ) do
          div(class: 'flex flex-col h-full') do
            if @logo
              code_path 'Renders sidebar with logo'
              div(class: 'flex items-center justify-between h-16 px-6 border-b') do
                if @logo.is_a?(Proc)
                  result = instance_exec(&@logo)
                  # If the proc returns a string, render it as raw HTML
                  raw safe(result) if result.is_a?(String)
                else
                  plain @logo
                end
              end
            end

            div(class: 'flex-1 overflow-y-auto') do
              if block_given?
                code_path 'Renders sidebar with content'
                if block.parameters.any? { |type, _| %i[opt req].include?(type) }
                  yield(self)
                else
                  yield
                end
              else
                code_path 'Renders empty sidebar'
              end
            end
          end
        end
      end

      # Creates a sidebar menu section
      def menu(**attrs, &_block)
        menu_class = ['hs-sidebar-menu flex flex-col space-y-1 p-4', attrs[:class]]
                     .compact
                     .join(' ')
                     .strip

        ul(class: menu_class, **attrs.except(:class)) do
          if block_given?
            code_path 'Renders menu with items'
            yield(SidebarMenuInterface.new(self))
          end
        end
      end

      private

      def sidebar_classes
        base = 'hs-sidebar fixed top-0 start-0 bottom-0 z-[60] w-64 bg-white border-e border-gray-200 overflow-y-auto'

        [base, @custom_class].compact.join(' ')
      end
    end

    # Interface class for sidebar menu
    class SidebarMenuInterface
      def initialize(sidebar)
        @sidebar = sidebar
      end

      def item(href: '#', active: false, icon: nil, badge: nil, **attrs, &block)
        item_classes = [
          'hs-sidebar-menu-item flex items-center gap-x-3 py-2 px-3 text-sm rounded-lg',
          active ? 'bg-gray-100 text-gray-900' : 'text-gray-700 hover:bg-gray-100',
          attrs[:class]
        ].compact.join(' ')

        @sidebar.li do
          @sidebar.a(
            href: href,
            class: item_classes,
            **attrs.except(:class)
          ) do
            if icon
              @sidebar.span(class: 'flex-shrink-0') do
                if icon.is_a?(Proc)
                  @sidebar.instance_exec(&icon)
                else
                  @sidebar.plain icon
                end
              end
            end

            @sidebar.span(class: 'flex-1') do
              @sidebar.instance_exec(&block) if block_given?
            end

            if badge
              @sidebar.span(class: 'inline-flex items-center gap-x-1.5 py-0.5 px-2 rounded-full text-xs font-medium bg-gray-100 text-gray-800') do
                @sidebar.plain badge
              end
            end
          end
        end
      end
    end

    # SidebarMenu component for sidebar navigation menu
    class SidebarMenu < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders sidebar menu component'
        ul(**@html_attrs, **@options, class: menu_classes) do
          if block_given?
            code_path 'Renders menu with items'
            yield(self)
          else
            code_path 'Renders empty menu'
          end
        end
      end

      private

      def menu_classes
        base = 'hs-sidebar-menu flex flex-col space-y-1 p-4'
        [base, @custom_class].compact.join(' ')
      end
    end

    # SidebarMenuItem component for individual sidebar menu items
    class SidebarMenuItem < ::Components::Preline::PrelineComponent
      # @param href [String] Link destination URL
      # @param active [Boolean] Whether item is currently active
      # @param icon [String, Proc] Optional icon content
      # @param badge [String] Optional badge text
      # @param attrs [Hash] Additional HTML attributes
      def initialize(href: '#', active: false, icon: nil, badge: nil, **attrs)
        @href = href
        @active = active
        @icon = icon
        @badge = badge

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders sidebar menu item'
        li do
          a(
            **@html_attrs,
            **@options,
            href: @href,
            class: item_classes
          ) do
            if @icon
              if @icon.is_a?(Proc)
                code_path 'Renders item with icon as proc'
              else
                code_path 'Renders item with icon'
              end
              span(class: 'flex-shrink-0') do
                if @icon.is_a?(Proc)
                  result = instance_exec(&@icon)
                  # If the proc returns a string, render it as raw HTML
                  raw safe(result) if result.is_a?(String)
                else
                  plain @icon
                end
              end
            end

            span(class: 'flex-1') do
              if block_given?
                code_path 'Renders item with content'
                yield
              else
                code_path 'Renders item without content'
              end
            end

            if @badge
              code_path 'Renders item with badge'
              span(class: badge_classes) { @badge }
            end
          end
        end
      end

      private

      def item_classes
        base = 'hs-sidebar-menu-item flex items-center gap-x-3 py-2 px-3 text-sm rounded-lg'
        if @active
          code_path 'Item is active'
          active_class = 'bg-gray-100 text-gray-900'
        else
          code_path 'Item is not active'
          active_class = 'text-gray-700 hover:bg-gray-100'
        end

        [base, active_class, @custom_class].compact.join(' ')
      end

      def badge_classes
        'inline-flex items-center gap-x-1.5 py-0.5 px-2 rounded-full text-xs font-medium bg-gray-100 text-gray-800'
      end
    end
  end
end
