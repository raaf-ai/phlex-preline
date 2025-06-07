# frozen_string_literal: true

module Components
  module Preline
    # Popover component for floating content panels triggered by user interaction
    #
    # @example Basic hover popover
    #   render Components::Preline::Popover.new(
    #     content: "This is helpful information"
    #   ) do
    #     Button(text: "Hover me", variant: :secondary)
    #   end
    #
    # @example Click-triggered popover with custom content
    #   render Components::Preline::Popover.new(
    #     trigger: :click,
    #     placement: :right
    #   ) do
    #     content do
    #       div(class: "p-3") do
    #         h4(class: "font-semibold mb-1") { "Popover Title" }
    #         p(class: "text-sm") { "Detailed explanation here" }
    #       end
    #     end
    #
    #     i(class: "fas fa-info-circle text-blue-500 cursor-pointer")
    #   end
    #
    # @example Bottom popover with arrow
    #   render Components::Preline::Popover.new(
    #     content: "Saved to clipboard!",
    #     placement: :bottom,
    #     trigger: :manual
    #   ) do
    #     Button(text: "Copy", icon: "copy")
    #   end
    class Popover < ::Components::Preline::PrelineComponent
      # @param content [String, Proc] Popover content (string or block)
      # @param placement [Symbol] Popover placement (:top, :bottom, :left, :right)
      # @param trigger [Symbol] Trigger type (:hover, :click, :manual)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(content:, placement: :top, trigger: :hover, **attrs)
        @content = content
        @placement = placement
        @trigger = trigger

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs, **@options, class: 'hs-popover inline-block',
                                       data: { 'hs-popover': '' }.merge(@html_attrs[:data] || {})) do
          # Trigger element
          div(class: 'hs-popover-toggle', data: { 'hs-popover-toggle': '' }) do
            yield if block_given?
          end

          # Popover content
          div(
            class: popover_classes,
            data: {
              'hs-popover-content': '',
              'hs-popover-placement': @placement,
              'hs-popover-trigger': @trigger
            }
          ) do
            if @content.is_a?(Proc)
              instance_eval(&@content)
            else
              plain @content
            end
          end
        end
      end

      private

      def popover_classes
        base = 'hs-popover-content transition-opacity opacity-0 invisible absolute z-10'
        style = 'inline-block px-3 py-2 text-sm font-medium text-white bg-gray-900 rounded-lg shadow-sm'

        [base, style, @custom_class].compact.join(' ')
      end
    end
  end
end
