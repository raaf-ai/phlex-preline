# frozen_string_literal: true

module Components
  module Preline
    # A toggle switch component with an optional count display
    #
    # This component provides a toggle switch with:
    # - Smooth animated transitions
    # - Optional count/badge display
    # - Size variants (small, default, large)
    # - Accessible checkbox implementation
    # - Disabled state support
    # - Customizable label and count visibility
    #
    # @example Basic toggle with count
    #   ToggleCount(
    #     name: "notifications",
    #     label: "Email Notifications",
    #     count: 5
    #   )
    #
    # @example Checked state with high count
    #   ToggleCount(
    #     name: "unread_messages",
    #     label: "Unread Messages",
    #     checked: true,
    #     count: 23
    #   )
    #
    # @example Large size without count display
    #   ToggleCount(
    #     name: "feature_flag",
    #     label: "Enable Beta Features",
    #     size: :lg,
    #     show_count: false,
    #     count: 3
    #   )
    #
    # @example Small toggle with zero count
    #   ToggleCount(
    #     name: "alerts",
    #     label: "System Alerts",
    #     size: :sm,
    #     count: 0  # Won't display when zero
    #   )
    #
    # @example Disabled toggle
    #   ToggleCount(
    #     name: "premium_feature",
    #     label: "Premium Feature",
    #     disabled: true,
    #     count: 10
    #   )
    class ToggleCount < ::Components::Preline::PrelineComponent
      # Initializes a new toggle count component
      #
      # @param name [String] Input field name attribute
      # @param attrs [Hash] Additional attributes
      # @option attrs [String] :id Custom ID (auto-generated if not provided)
      # @option attrs [Boolean] :checked Initial checked state (default: false)
      # @option attrs [Integer] :count Number to display (default: 0)
      # @option attrs [String] :label Label text for the toggle
      # @option attrs [Symbol] :size Size variant (:sm, :default, :lg) (default: :default)
      # @option attrs [Boolean] :disabled Whether the toggle is disabled (default: false)
      # @option attrs [Boolean] :show_count Whether to show the count (default: true)
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :data Data attributes
      # @option attrs [Hash] :aria ARIA attributes
      def initialize(name:, **attrs)
        @name = name
        @id = attrs.delete(:id) || "toggle_count_#{name}_#{SecureRandom.hex(4)}"
        @checked = attrs.delete(:checked) || false
        @count = attrs.delete(:count) || 0
        @label = attrs.delete(:label)
        @size = attrs.delete(:size) || :default
        @disabled = attrs.delete(:disabled) || false
        @show_count = attrs.delete(:show_count) || true

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs, class: wrapper_classes) do
          label(class: label_wrapper_classes) do
            input(
              type: 'checkbox',
              id: @id,
              name: @name,
              checked: @checked,
              disabled: @disabled,
              **@options,
              class: 'sr-only peer',
              data: { 'hs-toggle-count': '' }
            )

            # Toggle switch
            div(class: toggle_classes) do
              div(class: toggle_thumb_classes)
            end

            # Label and count
            div(class: 'ml-3') do
              span(class: text_classes) { @label } if @label

              if @show_count && @count.positive?
                span(class: count_classes) do
                  "(#{@count})"
                end
              end
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        ['hs-toggle-count-wrapper', @custom_class].compact.join(' ')
      end

      def label_wrapper_classes
        'flex items-center cursor-pointer'
      end

      def toggle_classes
        base = 'hs-toggle-count relative inline-flex flex-shrink-0 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500'

        size_class = case @size
                     when :sm then 'h-5 w-9'
                     when :lg then 'h-7 w-14'
                     else 'h-6 w-11'
                     end

        state_class = 'bg-gray-200 peer-checked:bg-blue-600'
        disabled_class = @disabled ? 'opacity-50 cursor-not-allowed' : ''

        [base, size_class, state_class, disabled_class].join(' ')
      end

      def toggle_thumb_classes
        base = 'hs-toggle-count-thumb pointer-events-none inline-block rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200'

        size_class = case @size
                     when :sm then 'h-4 w-4'
                     when :lg then 'h-6 w-6'
                     else 'h-5 w-5'
                     end

        position_class = case @size
                         when :sm then 'translate-x-0 peer-checked:translate-x-4'
                         when :lg then 'translate-x-0 peer-checked:translate-x-7'
                         else 'translate-x-0 peer-checked:translate-x-5'
                         end

        [base, size_class, position_class].join(' ')
      end

      def text_classes
        base = 'text-gray-900'
        size_class = case @size
                     when :sm then 'text-sm'
                     when :lg then 'text-lg'
                     else 'text-base'
                     end

        [base, size_class].join(' ')
      end

      def count_classes
        'hs-toggle-count-number ml-1 text-sm text-gray-500'
      end
    end
  end
end
