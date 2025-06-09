# frozen_string_literal: true

module Components
  module Preline
    # ButtonGroup component for grouping related buttons together
    #
    # @example Basic button group with yielding interface
    #   render Components::Preline::ButtonGroup.new do |group|
    #     group.button(text: "Left", variant: :secondary)
    #     group.button(text: "Middle", variant: :secondary)
    #     group.button(text: "Right", variant: :secondary)
    #   end
    #
    # @example With size and custom styling
    #   render Components::Preline::ButtonGroup.new(size: :sm) do |group|
    #     group.button(text: "Edit", icon: "edit", variant: :primary)
    #     group.button(text: "Delete", icon: "trash", variant: :danger)
    #   end
    #
    # @example Segmented control style
    #   render Components::Preline::ButtonGroup.new do |group|
    #     group.button(text: "Day", variant: :primary)
    #     group.button(text: "Week", variant: :secondary)
    #     group.button(text: "Month", variant: :secondary)
    #     group.button(text: "Year", variant: :secondary)
    #   end
    #
    # @example Button group with direct Button components
    #   render Components::Preline::ButtonGroup.new do
    #     Button(text: "Left", variant: :secondary)
    #     Button(text: "Middle", variant: :secondary)
    #     Button(text: "Right", variant: :secondary)
    #   end
    #
    # @example Using convenience methods
    #   render Components::Preline::ButtonGroup.new do |group|
    #     group.save_cancel  # Adds Save and Cancel buttons
    #   end
    #
    # @example CRUD action buttons
    #   render Components::Preline::ButtonGroup.new(size: :sm) do |group|
    #     group.crud_actions(
    #       actions: [:create, :read, :update, :delete],
    #       labels: { create: "New Item" }
    #     )
    #   end
    #
    # @example Toolbar with icon buttons
    #   render Components::Preline::ButtonGroup.new do |group|
    #     group.toolbar(tools: [
    #       { icon: "bold", title: "Bold", action: "bold" },
    #       { icon: "italic", title: "Italic", action: "italic" },
    #       { icon: "underline", title: "Underline", action: "underline" }
    #     ])
    #   end
    #
    # @example Toggle group for view options
    #   render Components::Preline::ButtonGroup.new do |group|
    #     group.toggle_group(
    #       name: "view-mode",
    #       options: [
    #         { text: "Grid", value: "grid", selected: true },
    #         { text: "List", value: "list" },
    #         { text: "Table", value: "table" }
    #       ]
    #     )
    #   end
    #
    # @example Mixed button types in one group
    #   render Components::Preline::ButtonGroup.new(size: :sm) do |group|
    #     group.button(text: "Back", icon: "arrow-left", variant: :secondary)
    #     group.button(text: "Save Draft", variant: :secondary)
    #     group.button(text: "Preview", icon: "eye", variant: :secondary)
    #     group.button(text: "Publish", icon: "check", variant: :primary)
    #   end
    #
    # @example Action buttons with custom attributes
    #   render Components::Preline::ButtonGroup.new do |group|
    #     group.button(
    #       text: "Download",
    #       icon: "download",
    #       variant: :secondary,
    #       data: { turbo_method: :post }
    #     )
    #     group.button(
    #       text: "Share",
    #       icon: "share",
    #       variant: :secondary,
    #       data: { bs_toggle: "modal", bs_target: "#shareModal" }
    #     )
    #   end
    #
    # @example Pagination controls
    #   render Components::Preline::ButtonGroup.new do |group|
    #     group.button(text: "Previous", icon: "chevron-left", variant: :secondary, disabled: current_page == 1)
    #     (1..total_pages).each do |page|
    #       group.button(
    #         text: page.to_s,
    #         variant: page == current_page ? :primary : :secondary,
    #         href: "?page=#{page}"
    #       )
    #     end
    #     group.button(text: "Next", icon: "chevron-right", icon_position: :right, variant: :secondary, disabled: current_page == total_pages)
    #   end
    #
    # @example Form actions with different button types
    #   render Components::Preline::ButtonGroup.new do |group|
    #     group.button(text: "Reset", type: "reset", variant: :secondary)
    #     group.button(text: "Cancel", href: "/dashboard", variant: :secondary)
    #     group.button(text: "Save Changes", type: "submit", variant: :primary, icon: "save")
    #   end
    #
    # @example Icon-only action buttons
    #   render Components::Preline::ButtonGroup.new(size: :sm) do |group|
    #     group.icon_button(icon: "edit", title: "Edit item", variant: :secondary)
    #     group.icon_button(icon: "copy", title: "Duplicate item", variant: :secondary)
    #     group.icon_button(icon: "trash", title: "Delete item", variant: :danger)
    #   end
    class ButtonGroup < ::Components::Preline::PrelineComponent
      # @param size [Symbol] Size of the button group (:sm, :default, :lg)
      # @param variant [Symbol] Visual variant of the group (:default, :primary, etc.)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(size: :default, variant: :default, **attrs)
        @size = validate_size!(size)
        @variant = validate_variant!(variant)
        @yielded_buttons = []

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders button group component'
        div(**@html_attrs, **@options, class: button_group_classes, role: 'group') do
          if block_given?
            # Try to determine if this is a yielding interface by calling with self
            initial_buttons = @yielded_buttons.length
            yield(self)

            # If buttons were added, we're using the yielding interface
            render_yielded_buttons if @yielded_buttons.length > initial_buttons
            # If no buttons were added, the content was already rendered by yield
          end
        end
      end

      # Adds a button to the group
      #
      # @param text [String] Button text
      # @param variant [Symbol] Button variant (:primary, :secondary, :success, :danger, etc.)
      # @param size [Symbol] Button size (:xs, :sm, :md, :lg, :xl)
      # @param icon [String, nil] FontAwesome icon name
      # @param icon_position [Symbol] Icon position (:left or :right)
      # @param href [String, nil] URL to make the button a link
      # @param type [String] Button type (button, submit, reset)
      # @param disabled [Boolean] Whether the button is disabled
      # @param attrs [Hash] Additional HTML attributes
      def button(text:, variant: nil, size: nil, icon: nil, icon_position: :left, href: nil, type: 'button', disabled: false, **attrs)
        button_attrs = {
          text: text,
          variant: variant || @variant,
          size: size || @size,
          icon: icon,
          icon_position: icon_position,
          href: href,
          type: type,
          disabled: disabled
        }.merge(attrs)

        @yielded_buttons << button_attrs
      end

      # Adds an icon-only button to the group
      #
      # @param icon [String] FontAwesome icon name
      # @param variant [Symbol] Button variant
      # @param size [Symbol] Button size
      # @param title [String] Tooltip/title for accessibility
      # @param attrs [Hash] Additional HTML attributes
      def icon_button(icon:, variant: nil, size: nil, title: nil, **attrs)
        attrs[:title] = title if title
        attrs[:'aria-label'] = title if title
        button(text: '', icon: icon, variant: variant, size: size, **attrs)
      end

      # Adds a save/cancel button pair
      #
      # @param save_text [String] Text for save button (default: "Save")
      # @param cancel_text [String] Text for cancel button (default: "Cancel")
      # @param save_attrs [Hash] Additional attributes for save button
      # @param cancel_attrs [Hash] Additional attributes for cancel button
      def save_cancel(save_text: 'Save', cancel_text: 'Cancel', save_attrs: {}, cancel_attrs: {})
        button(text: save_text, variant: :primary, icon: 'check', **save_attrs)
        button(text: cancel_text, variant: :secondary, icon: 'times', **cancel_attrs)
      end

      # Adds edit/delete button pair
      #
      # @param edit_text [String] Text for edit button (default: "Edit")
      # @param delete_text [String] Text for delete button (default: "Delete")
      # @param edit_attrs [Hash] Additional attributes for edit button
      # @param delete_attrs [Hash] Additional attributes for delete button
      def edit_delete(edit_text: 'Edit', delete_text: 'Delete', edit_attrs: {}, delete_attrs: {})
        button(text: edit_text, variant: :primary, icon: 'edit', **edit_attrs)
        button(text: delete_text, variant: :danger, icon: 'trash', **delete_attrs)
      end

      # Adds CRUD action buttons
      #
      # @param actions [Array<Symbol>] Actions to include (:create, :read, :update, :delete)
      # @param labels [Hash] Custom labels for actions
      def crud_actions(actions: %i[create read update delete], labels: {})
        default_labels = {
          create: 'Create',
          read: 'View',
          update: 'Edit',
          delete: 'Delete'
        }

        action_configs = {
          create: { icon: 'plus', variant: :primary },
          read: { icon: 'eye', variant: :secondary },
          update: { icon: 'edit', variant: :primary },
          delete: { icon: 'trash', variant: :danger }
        }

        actions.each do |action|
          config = action_configs[action]
          label = labels[action] || default_labels[action]
          button(text: label, icon: config[:icon], variant: config[:variant])
        end
      end

      # Creates a toggle group (radio button style)
      #
      # @param options [Array<Hash>] Array of options with :text, :value, and optional :selected
      # @param name [String] Name attribute for radio behavior
      def toggle_group(options:, name:)
        options.each do |option|
          variant = option[:selected] ? :primary : :secondary
          attrs = {
            data: {
              toggle: 'button',
              value: option[:value],
              name: name
            }
          }
          button(text: option[:text], variant: variant, **attrs)
        end
      end

      # Creates a toolbar-style group of icon buttons
      #
      # @param tools [Array<Hash>] Array of tool configurations with :icon, :title, and optional :action
      def toolbar(tools:)
        tools.each do |tool|
          # Use data attributes instead of onclick for security
          attrs = tool[:action] ? { data: { action: tool[:action] } } : {}
          icon_button(icon: tool[:icon], title: tool[:title], variant: :secondary, **attrs)
        end
      end

      private

      def render_yielded_buttons
        @yielded_buttons.each_with_index do |button_attrs, index|
          is_first = index.zero?
          is_last = index == @yielded_buttons.length - 1

          # Add button group specific classes
          group_classes = build_button_group_item_classes(is_first, is_last)
          merged_attrs = button_attrs.dup
          merged_attrs[:class] = [merged_attrs[:class], group_classes].compact.join(' ').strip

          # Create a Button element directly
          if merged_attrs[:href]
            a(**merged_attrs.except(:text, :icon, :icon_position, :variant, :size, :disabled),
              href: merged_attrs[:href],
              class: build_button_classes(merged_attrs, group_classes)) do
              render_button_content(merged_attrs)
            end
          else
            # Create HTML button element directly to avoid method name conflict
            tag_attrs = merged_attrs.except(:text, :icon, :icon_position, :variant, :size, :disabled, :href)
            tag_attrs[:type] = merged_attrs[:type] || 'button'
            tag_attrs[:disabled] = merged_attrs[:disabled] if merged_attrs[:disabled]
            tag_attrs[:class] = build_button_classes(merged_attrs, group_classes)

            tag(:button, **tag_attrs) do
              render_button_content(merged_attrs)
            end
          end
        end
      end

      def build_button_classes(button_attrs, group_classes)
        variant = button_attrs[:variant] || :secondary
        size = button_attrs[:size] || @size

        base_classes = case variant.to_sym
                       when :primary
                         'bg-blue-600 hover:bg-blue-700 text-white border border-blue-600'
                       when :success
                         'bg-green-600 hover:bg-green-700 text-white border border-green-600'
                       when :danger
                         'bg-red-600 hover:bg-red-700 text-white border border-red-600'
                       when :warning
                         'bg-yellow-600 hover:bg-yellow-700 text-white border border-yellow-600'
                       when :info
                         'bg-blue-500 hover:bg-blue-600 text-white border border-blue-500'
                       else # :secondary, :default, or any other value
                         'bg-white hover:bg-gray-50 text-gray-900 border border-gray-300'
                       end

        size_classes = case size.to_sym
                       when :xs
                         'px-2 py-1 text-xs'
                       when :sm
                         'px-3 py-1.5 text-sm'
                       when :lg
                         'px-4 py-2.5 text-lg'
                       when :xl
                         'px-6 py-3 text-xl'
                       else
                         'px-4 py-2 text-sm'
                       end

        [
          'inline-flex items-center justify-center font-medium transition-colors duration-200',
          base_classes,
          size_classes,
          group_classes,
          button_attrs[:class]
        ].compact.join(' ').strip
      end

      def render_button_content(button_attrs)
        i(class: "fas fa-#{button_attrs[:icon]} mr-2") if button_attrs[:icon] && button_attrs[:icon_position] == :left

        plain button_attrs[:text] if button_attrs[:text]

        return unless button_attrs[:icon] && button_attrs[:icon_position] == :right

        i(class: "fas fa-#{button_attrs[:icon]} ml-2")
      end

      def build_button_group_item_classes(is_first, is_last)
        classes = []

        classes << if is_first
                     'rounded-r-none'
                   elsif is_last
                     'rounded-l-none -ml-px'
                   else
                     'rounded-none -ml-px'
                   end

        classes.join(' ')
      end

      def button_group_classes
        base = 'hs-button-group inline-flex shadow-sm'

        [base, @custom_class].compact.join(' ')
      end

      def validate_size!(size)
        valid_sizes = %i[xs sm default md lg xl]
        return size if valid_sizes.include?(size)

        raise ArgumentError, "Invalid size: #{size}. Valid options are: #{valid_sizes.join(', ')}"
      end

      def validate_variant!(variant)
        valid_variants = %i[default primary secondary success danger warning info]
        return variant if valid_variants.include?(variant)

        raise ArgumentError, "Invalid variant: #{variant}. Valid options are: #{valid_variants.join(', ')}"
      end
    end
  end
end
