# frozen_string_literal: true

module Components
  module Preline
    # ButtonGroup component for grouping related buttons together
    #
    # @example Basic button group
    #   render Components::Preline::ButtonGroup.new do
    #     Button(text: "Left", variant: :secondary)
    #     Button(text: "Middle", variant: :secondary)
    #     Button(text: "Right", variant: :secondary)
    #   end
    #
    # @example With size and custom styling
    #   render Components::Preline::ButtonGroup.new(size: :sm) do
    #     Button(text: "Edit", icon: "edit", variant: :primary, size: :sm)
    #     Button(text: "Delete", icon: "trash", variant: :danger, size: :sm)
    #   end
    #
    # @example Segmented control style
    #   render Components::Preline::ButtonGroup.new do
    #     Button(text: "Day", variant: :primary)
    #     Button(text: "Week", variant: :secondary)
    #     Button(text: "Month", variant: :secondary)
    #     Button(text: "Year", variant: :secondary)
    #   end
    class ButtonGroup < ::Components::Preline::PrelineComponent
      # @param size [Symbol] Size of the button group (:sm, :default, :lg)
      # @param variant [Symbol] Visual variant of the group (:default, :primary, etc.)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(size: :default, variant: :default, **attrs)
        @size = size
        @variant = variant

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders button group component'
        div(**@html_attrs, **@options, class: button_group_classes, role: 'group') do
          yield if block_given?
        end
      end

      private

      def button_group_classes
        base = 'hs-button-group inline-flex shadow-sm'

        [base, @custom_class].compact.join(' ')
      end
    end
  end
end
