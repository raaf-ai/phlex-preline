# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI tabs component for organizing content into switchable panels.
    # Supports various styles, alignments, and both horizontal and vertical layouts.
    #
    # @example Basic tabs with yielding interface
    #   render Components::Preline::Tabs.new do |tabs|
    #     tabs.nav do |nav|
    #       nav.tab(active: true) { "Tab 1" }
    #       nav.tab { "Tab 2" }
    #       nav.tab { "Tab 3" }
    #     end
    #     tabs.content do |content|
    #       content.pane(active: true) { "Content for Tab 1" }
    #       content.pane { "Content for Tab 2" }
    #       content.pane { "Content for Tab 3" }
    #     end
    #   end
    #
    # @example Tabs with nested components
    #   render Components::Preline::Tabs.new(
    #     tabs: [
    #       { title: "Tab 1", pane_id: "tab1", active: true },
    #       { title: "Tab 2", pane_id: "tab2" }
    #     ]
    #   ) do
    #     tab_pane(id: "tab1", active: true) { "Content 1" }
    #     tab_pane(id: "tab2") { "Content 2" }
    #   end
    #
    # @example Pills style with icons and badges
    #   render Components::Preline::Tabs.new(
    #     tabs: [
    #       { title: "Overview", icon: "home", pane_id: "overview", active: true },
    #       { title: "Messages", icon: "envelope", pane_id: "messages", badge: "3" },
    #       { title: "Settings", icon: "cog", pane_id: "settings" }
    #     ],
    #     type: :pills,
    #     alignment: :center
    #   )
    class Tabs < ::Components::Preline::PrelineComponent
      TYPES = {
        default: '',
        pills: 'hs-tabs-pills',
        underline: 'hs-tabs-underline',
        bordered: 'hs-tabs-bordered'
      }.freeze

      ALIGNMENTS = {
        start: '',
        center: 'hs-tabs-center',
        end: 'hs-tabs-end'
      }.freeze

      def initialize(
        tabs: [],
        type: :default,
        alignment: :start,
        fill: false,
        vertical: false,
        nav_class: '',
        content_class: '',
        id: nil,
        **attrs
      )
        @tabs = tabs
        @type = type
        @alignment = alignment
        @fill = fill
        @vertical = vertical
        @custom_class = attrs.delete(:class)
        @nav_class = nav_class
        @content_class = content_class
        @id = id || "tabs-#{SecureRandom.hex(4)}"
      end

      def view_template(&block)
        code_path 'Renders tabs component'
        div(
          class: build_wrapper_classes,
          data: { 'hs-tabs': true }
        ) do
          if block_given? && block.parameters.any? { |type, _| %i[opt req].include?(type) }
            yield(self)
          else
            render_nav
            render_content(&block)
          end
        end
      end

      # Creates tabs navigation section
      def nav(**attrs, &_block)
        @nav_attrs = attrs
        @nav_items = []
        yield(TabsNavInterface.new(self)) if block_given?

        ul(
          class: build_nav_classes(attrs[:class]),
          role: 'tablist'
        ) do
          @nav_items.each_with_index do |item, index|
            render_yielded_tab_item(item, index)
          end
        end
      end

      # Creates tabs content section
      def content(**attrs, &_block)
        @content_attrs = attrs
        @content_panes = []
        yield(TabsContentInterface.new(self)) if block_given?

        classes = ['hs-tab-content', @content_class, attrs[:class]]
                  .compact
                  .join(' ')
                  .strip
        div(class: classes) do
          @content_panes.each_with_index do |pane, index|
            render_yielded_pane(pane, index)
          end
        end
      end

      # Store nav item for rendering
      def add_nav_item(item)
        @nav_items ||= []
        @nav_items << item
      end

      # Store content pane for rendering
      def add_content_pane(pane)
        @content_panes ||= []
        @content_panes << pane
      end

      def tab_pane(id:, active: false)
        code_path 'Renders tab pane'
        code_path 'Renders active tab pane' if active
        div(
          id: id,
          class: "hs-tab-pane #{'hs-tab-pane-active' if active}",
          role: 'tabpanel',
          aria: { labelledby: "#{id}-tab" }
        ) do
          yield if block_given?
        end
      end

      private

      def build_wrapper_classes
        classes = ['hs-tabs']
        if @vertical
          code_path 'Renders vertical tabs'
          classes << 'hs-tabs-vertical'
        end
        classes << @custom_class
        classes.join(' ').strip
      end

      def render_nav
        code_path 'Renders tabs navigation'
        ul(
          class: build_nav_classes,
          role: 'tablist'
        ) do
          @tabs.each_with_index do |tab, index|
            render_tab_nav_item(tab, index)
          end
        end
      end

      def render_tab_nav_item(tab, index)
        # Only mark first tab as active if no explicit active tab is set
        active = if tab.key?(:active)
                   tab[:active]
                 else
                   index.zero? && @tabs.none? { |t| t[:active] }
                 end

        tab_id = tab[:id] || "#{@id}-tab-#{index}"
        pane_id = tab[:pane_id] || "#{@id}-pane-#{index}"

        code_path 'Renders active tab item' if active

        li(class: 'hs-tab-item', role: 'presentation') do
          button(
            id: "#{tab_id}-tab",
            class: "hs-tab-link #{'hs-tab-active' if active}",
            data: { 'hs-tab': "##{pane_id}" },
            aria: {
              controls: pane_id,
              selected: active.to_s
            },
            role: 'tab'
          ) do
            if tab[:icon]
              code_path 'Renders tab with icon'
              i(class: "fas fa-#{tab[:icon]} mr-2")
            end

            span { tab[:title] }

            if tab[:badge]
              code_path 'Renders tab with badge'
              span(class: 'hs-tab-badge ml-2') do
                if tab[:badge].is_a?(Hash)
                  code_path 'Renders tab with badge component'
                  # Convert label to text for Badge component
                  badge_attrs = tab[:badge].dup
                  badge_attrs[:text] ||= badge_attrs.delete(:label)
                  render Badge.new(**badge_attrs)
                else
                  plain tab[:badge].to_s
                end
              end
            end
          end
        end
      end

      def render_content
        code_path 'Renders tab content area'
        div(class: "hs-tab-content #{@content_class}".strip) do
          if block_given?
            code_path 'Renders custom tab content'
            yield
          else
            code_path 'Renders automatic tab panes'
            render_tab_panes
          end
        end
      end

      def render_tab_panes
        @tabs.each_with_index do |tab, index|
          # Use same logic as render_tab_nav_item for consistency
          active = if tab.key?(:active)
                     tab[:active]
                   else
                     index.zero? && @tabs.none? { |t| t[:active] }
                   end
          pane_id = tab[:pane_id] || "#{@id}-pane-#{index}"

          tab_pane(id: pane_id, active: active) do
            if tab[:content].respond_to?(:call)
              code_path 'Renders tab content from proc'
              instance_exec(&tab[:content])
            elsif tab[:content]
              code_path 'Renders tab content from string'
              plain tab[:content]
            end
          end
        end
      end

      def build_nav_classes(additional_class = nil)
        classes = ['hs-tabs-nav']
        if TYPES[@type].present?
          code_path "Renders #{@type} tabs style"
          classes << TYPES[@type]
        end
        if ALIGNMENTS[@alignment].present?
          code_path "Renders #{@alignment} aligned tabs"
          classes << ALIGNMENTS[@alignment]
        end
        if @fill
          code_path 'Renders fill width tabs'
          classes << 'hs-tabs-fill'
        end
        classes << @nav_class
        classes << additional_class
        classes.compact.join(' ').strip
      end

      def render_yielded_tab_item(item, index)
        tab_id = "#{@id}-tab-#{index}"
        pane_id = "#{@id}-pane-#{index}"
        active = item[:active] || (index.zero? && @nav_items.none? { |i| i[:active] })

        code_path 'Renders active tab item' if active

        li(class: 'hs-tab-item', role: 'presentation') do
          button(
            id: "#{tab_id}-tab",
            class: "hs-tab-link #{'hs-tab-active' if active}",
            data: { 'hs-tab': "##{pane_id}" },
            aria: {
              controls: pane_id,
              selected: active.to_s
            },
            role: 'tab',
            **item[:attrs]
          ) do
            if item[:icon]
              code_path 'Renders tab with icon'
              i(class: "fas fa-#{item[:icon]} mr-2")
            end
            instance_exec(&item[:content]) if item[:content]
            if item[:badge]
              code_path 'Renders tab with badge'
              span(class: 'hs-tab-badge ml-2') { item[:badge] }
            end
          end
        end
      end

      def render_yielded_pane(pane, index)
        pane_id = "#{@id}-pane-#{index}"
        active = pane[:active] || (index.zero? && @content_panes.none? { |p| p[:active] })

        code_path 'Renders tab pane'
        code_path 'Renders active tab pane' if active
        div(
          id: pane_id,
          class: "hs-tab-pane #{'hs-tab-pane-active' if active}",
          role: 'tabpanel',
          aria: { labelledby: "#{@id}-tab-#{index}-tab" },
          **pane[:attrs]
        ) do
          instance_exec(&pane[:content]) if pane[:content]
        end
      end
    end

    # Interface class for tabs navigation
    class TabsNavInterface
      def initialize(tabs)
        @tabs = tabs
      end

      def tab(active: false, icon: nil, badge: nil, **attrs, &block)
        @tabs.add_nav_item({
                             active: active,
                             icon: icon,
                             badge: badge,
                             attrs: attrs,
                             content: block
                           })
      end
    end

    # Interface class for tabs content
    class TabsContentInterface
      def initialize(tabs)
        @tabs = tabs
      end

      def pane(active: false, **attrs, &block)
        @tabs.add_content_pane({
                                 active: active,
                                 attrs: attrs,
                                 content: block
                               })
      end
    end
  end
end
