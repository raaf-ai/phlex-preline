# frozen_string_literal: true

module Components
  module Preline
    # TreeView component for hierarchical data display
    #
    # @example Basic tree view with yielding interface
    #   TreeView.new do |tree|
    #     tree.node(label: "Documents") do |node|
    #       node.item(label: "Resume.pdf")
    #       node.item(label: "Cover Letter.docx")
    #     end
    #     tree.node(label: "Images") do |node|
    #       node.item(label: "Profile.jpg")
    #       node.item(label: "Banner.png")
    #     end
    #   end
    #
    # @example Tree with icons and badges
    #   TreeView.new do |tree|
    #     tree.node(label: "Inbox", icon: "inbox", badge: "3") do |node|
    #       node.item(label: "Unread", icon: "envelope", badge: "2")
    #       node.item(label: "Starred", icon: "star")
    #     end
    #     tree.item(label: "Sent", icon: "paper-plane")
    #   end
    #
    # @example Selectable tree with checkboxes
    #   TreeView.new(selectable: true) do |tree|
    #     tree.node(label: "Select All") do |node|
    #       node.item(label: "Option 1", selected: true)
    #       node.item(label: "Option 2")
    #       node.item(label: "Option 3")
    #     end
    #   end
    #
    # @example Tree view with items array
    #   TreeView(items: [
    #     { label: "Documents", children: [
    #       { label: "Resume.pdf" },
    #       { label: "Cover Letter.docx" }
    #     ]},
    #     { label: "Images", children: [
    #       { label: "Profile.jpg" },
    #       { label: "Banner.png" }
    #     ]}
    #   ])
    #
    # @example Tree with links
    #   TreeView.new do |tree|
    #     tree.item(label: "Home", href: "/", icon: "home")
    #     tree.node(label: "Products", href: "/products") do |node|
    #       node.item(label: "Category A", href: "/products/a")
    #       node.item(label: "Category B", href: "/products/b")
    #     end
    #   end
    class TreeView < ::Components::Preline::PrelineComponent
      # @param items [Array<Hash>] Tree items with :label, :children, :icon, :badge, :href, :selected, :value
      # @param expanded [Boolean] Whether tree nodes are expanded by default
      # @param selectable [Boolean] Whether items can be selected (adds checkboxes/radios)
      # @param attrs [Hash] Additional HTML attributes
      # @option attrs [String] :class CSS classes to add to the tree container
      # @option attrs [String] :id HTML ID attribute
      # @option attrs [Hash] :data Data attributes
      def initialize(items: [], expanded: false, selectable: false, **attrs)
        @items = items
        @expanded = expanded
        @selectable = selectable
        @custom_class = attrs.delete(:class)
        @data_attrs = attrs.delete(:data) || {}
        @html_attrs = attrs
        @yielded_items = []
      end

      def view_template
        div(
          **@html_attrs,
          class: tree_classes,
          data: @data_attrs.merge({ 'hs-tree-view': '' })
        ) do
          ul(class: 'hs-tree-view-root') do
            if @items.any?
              @items.each do |item|
                render_tree_item(item)
              end
            elsif block_given?
              # Try to determine if this is a yielding interface by calling with self
              # If the block accepts the parameter, items will be added to @yielded_items
              initial_items = @yielded_items.length
              yield(self)

              # If items were added, we're using the yielding interface
              if @yielded_items.length > initial_items
                @yielded_items.each do |item|
                  render_tree_item(item)
                end
              end
              # If no items were added, the content was already rendered by yield
            end
          end
        end
      end

      # Creates a tree node (parent item with children)
      def node(label:, icon: nil, badge: nil, href: nil, selected: false, value: nil, **attrs, &_block)
        node_attrs = {
          label: label,
          icon: icon,
          badge: badge,
          href: href,
          selected: selected,
          value: value,
          children: []
        }.merge(attrs)

        if block_given?
          interface = TreeNodeInterface.new(node_attrs[:children])
          yield(interface)
        end

        @yielded_items << node_attrs
      end

      # Creates a tree item (leaf node)
      def item(label:, icon: nil, badge: nil, href: nil, selected: false, value: nil, **attrs)
        @yielded_items << {
          label: label,
          icon: icon,
          badge: badge,
          href: href,
          selected: selected,
          value: value
        }.merge(attrs)
      end

      private

      def tree_classes
        base = 'hs-tree-view'
        [base, @custom_class].compact.join(' ')
      end

      def render_tree_item(item, level = 0)
        li(class: 'hs-tree-view-item') do
          if item[:children]&.any?
            render_parent_item(item, level)
            render_children(item[:children], level + 1)
          else
            render_leaf_item(item, level)
          end
        end
      end

      def render_parent_item(item, level)
        div(class: 'hs-tree-view-node flex items-center') do
          # Toggle button
          button(
            type: 'button',
            class: 'hs-tree-view-toggle p-0.5 mr-1',
            data: {
              'hs-tree-view-toggle': '',
              'hs-tree-view-open': @expanded ? 'true' : nil
            }.compact,
            aria: { expanded: @expanded ? 'true' : 'false' }
          ) do
            render_toggle_icon
          end

          # Node content
          render_node_content(item, level)
        end
      end

      def render_leaf_item(item, level)
        div(
          class: 'hs-tree-view-node hs-tree-view-leaf flex items-center',
          style: "padding-left: #{(level * 1.5) + 1.5}rem"
        ) do
          render_node_content(item, level)
        end
      end

      def render_node_content(item, _level)
        if @selectable
          label(class: 'flex items-center cursor-pointer hover:bg-gray-50 rounded px-2 py-1') do
            input(
              type: item[:radio] ? 'radio' : 'checkbox',
              name: item[:radio] ? 'tree-selection' : nil,
              value: item[:value] || item[:label],
              checked: item[:selected],
              class: 'mr-2 text-blue-600'
            )
            render_item_label(item)
          end
        else
          a(
            href: item[:href] || '#',
            class: 'flex items-center hover:bg-gray-50 rounded px-2 py-1 text-gray-700 hover:text-gray-900'
          ) do
            render_item_label(item)
          end
        end
      end

      def render_item_label(item)
        i(class: "fas fa-#{item[:icon]} mr-2 text-gray-400") if item[:icon]

        span(class: 'hs-tree-view-label') { item[:label] }

        return unless item[:badge]

        span(class: 'ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800') do
          item[:badge]
        end
      end

      def render_children(children, level)
        ul(
          class: 'hs-tree-view-group mt-1',
          style: @expanded ? nil : 'display: none'
        ) do
          children.each do |child|
            render_tree_item(child, level)
          end
        end
      end

      def render_toggle_icon
        svg(
          class: 'hs-tree-view-icon size-4 text-gray-600 transition-transform duration-200',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          viewBox: '0 0 24 24'
        ) do |s|
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M9 5l7 7-7 7'
          )
        end
      end
    end

    # Interface class for tree nodes
    class TreeNodeInterface
      def initialize(children_array)
        @children = children_array
      end

      # Creates a child tree node
      def node(label:, icon: nil, badge: nil, href: nil, selected: false, value: nil, **attrs, &_block)
        node_attrs = {
          label: label,
          icon: icon,
          badge: badge,
          href: href,
          selected: selected,
          value: value,
          children: []
        }.merge(attrs)

        if block_given?
          interface = TreeNodeInterface.new(node_attrs[:children])
          yield(interface)
        end

        @children << node_attrs
      end

      # Creates a child tree item
      def item(label:, icon: nil, badge: nil, href: nil, selected: false, value: nil, **attrs)
        @children << {
          label: label,
          icon: icon,
          badge: badge,
          href: href,
          selected: selected,
          value: value
        }.merge(attrs)
      end
    end
  end
end
