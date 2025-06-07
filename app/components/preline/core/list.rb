# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI list component for displaying structured content.
    # Supports various list styles, interactive states, and rich list items.
    #
    # @example Basic list with string items
    #   render Components::Preline::List.new(
    #     items: ["First item", "Second item", "Third item"]
    #   )
    #
    # @example Divided list with rich content
    #   render Components::Preline::List.new(
    #     type: :divided,
    #     hoverable: true,
    #     items: [
    #       { title: "John Doe", subtitle: "john@example.com", icon: "user" },
    #       { title: "Jane Smith", subtitle: "jane@example.com", icon: "user" }
    #     ]
    #   )
    #
    # @example Custom list with block
    #   render Components::Preline::List.new(type: :bordered) do |list|
    #     list.list_item do
    #       h4 { "Custom content" }
    #       p { "With multiple elements" }
    #     end
    #     list.list_item(text: "Simple text item")
    #   end
    class List < ::Components::Preline::PrelineComponent
      TYPES = {
        default: '',
        divided: 'hs-list-divided',
        bordered: 'hs-list-bordered',
        striped: 'hs-list-striped'
      }.freeze

      # Initialize a new List component
      #
      # @param items [Array<String, Hash>] List items (strings or hashes with title, subtitle, icon, actions)
      # @param type [Symbol] List style type (:default, :divided, :bordered, :striped)
      # @param ordered [Boolean] Use ordered list (<ol>) instead of unordered (<ul>)
      # @param inline [Boolean] Display list items inline
      # @param unstyled [Boolean] Remove default list styling
      # @param marker [Symbol] List marker style (:disc, :circle, :square, :decimal)
      # @param hoverable [Boolean] Enable hover effect on items
      # @param selectable [Boolean] Enable selection styling on items
      # @param class [String] Additional CSS classes for the list
      # @param item_class [String] Additional CSS classes for all list items
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        items:,
        type: :default,
        ordered: false,
        inline: false,
        unstyled: false,
        marker: nil,
        hoverable: false,
        selectable: false,
        item_class: '',
        **attrs
      )
        @items = items # Allow empty arrays
        @type = validate_inclusion!(type, 'type', TYPES.keys)
        @ordered = validate_boolean!(ordered, 'ordered')
        @inline = validate_boolean!(inline, 'inline')
        @unstyled = validate_boolean!(unstyled, 'unstyled')
        @marker = marker
        @hoverable = validate_boolean!(hoverable, 'hoverable')
        @selectable = validate_boolean!(selectable, 'selectable')
        @item_class = validate_css_class!(item_class)

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders list component'
        list_attrs = component_attributes(additional_classes: build_classes)

        list_tag = @ordered ? :ol : :ul
        send(list_tag, **list_attrs) do
          if block_given?
            yield(self)
          else
            render_items
          end
        end
      end

      # Create a list item within the list
      #
      # @param options [Hash] Options for the list item
      # @option options [String] :text Simple text content for the item
      # @option options [String] :class Additional CSS classes for the item
      # @yield Block for custom item content
      def list_item(**options)
        li(class: build_item_classes(options), **options.except(:class)) do
          if block_given?
            yield
          elsif options[:text]
            plain options[:text]
          end
        end
      end

      private

      def build_classes
        classes = ['hs-list']
        classes << TYPES[@type] if TYPES[@type].present?

        if @ordered
          code_path 'Renders with ordered'
          classes << 'hs-list-ordered'
        end

        if @hoverable
          code_path 'Renders with hoverable'
          classes << 'hs-list-hoverable'
        end

        classes << 'hs-list-selectable' if @selectable

        if @inline
          code_path 'Renders with inline'
          classes << 'hs-list-inline'
        end

        if @unstyled
          code_path 'Renders with unstyled'
          classes << 'hs-list-unstyled'
        end

        classes << "hs-list-marker-#{@marker}" if @marker

        classes # Return array, not joined string
      end

      def build_item_classes(options = {})
        classes = ['hs-list-item']
        classes << @item_class
        classes << options[:class] if options[:class]
        classes.join(' ').strip
      end

      def render_items
        @items.each do |item|
          case item
          when Hash
            render_hash_item(item)
          when String
            list_item(text: item)
          else
            list_item { item.to_s }
          end
        end
      end

      def render_hash_item(item)
        list_item(**item.except(:content, :actions, :icon, :title, :subtitle, :text)) do
          if item[:icon]
            code_path 'Renders with icon'
            i(class: "fas fa-#{item[:icon]} mr-2")
          end

          if item[:title] || item[:subtitle]
            div(class: 'hs-flex-grow') do
              h4(class: 'hs-list-item-title') { plain item[:title] } if item[:title]
              p(class: 'hs-list-item-text') { plain item[:subtitle] } if item[:subtitle]
            end
          elsif item[:content]
            if item[:content].is_a?(Proc)
              instance_exec(&item[:content])
            else
              div(class: 'hs-flex-grow') { plain item[:content] }
            end
          else
            plain item[:text] || ''
          end

          if item[:actions]
            div(class: 'hs-list-item-actions') do
              item[:actions].each { |action| render_action(action) }
            end
          end
        end
      end

      def render_action(action)
        case action[:type]
        when :link
          Link(**action.except(:type))
        when :button
          Button(**action.except(:type))
        else
          span { action[:text] }
        end
      end
    end
  end
end
