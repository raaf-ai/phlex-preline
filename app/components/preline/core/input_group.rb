# frozen_string_literal: true

module Components
  module Preline
    # InputGroup component for grouping form inputs with addons
    #
    # @example Basic input group with text addon
    #   InputGroup do
    #     InputGroupText { "@" }
    #     Input(placeholder: "Username")
    #   end
    #
    # @example Input group with icon addon at end
    #   InputGroup do
    #     Input(placeholder: "Email")
    #     InputGroupText(position: :end) do
    #       i(class: "fas fa-envelope")
    #     end
    #   end
    #
    # @example Input group with button
    #   InputGroup do
    #     Input(placeholder: "Search...")
    #     Button(variant: :primary) { "Search" }
    #   end
    class InputGroup < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes for the input group container
      # @option attrs [String] :class CSS classes to add to the input group
      # @option attrs [String] :id HTML ID attribute
      # @option attrs [Hash] :data Data attributes
      def initialize(**attrs)
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs
      end

      def view_template(&block)
        code_path 'Renders input group component'
        div(**@html_attrs, class: input_group_classes) do
          if block
            code_path 'Renders input group with content'
            content = capture(&block)
            if content.is_a?(String)
              plain content
            else
              raw(content)
            end
          else
            code_path 'Renders empty input group'
          end
        end
      end

      private

      def input_group_classes
        base = 'hs-input-group flex rounded-lg shadow-sm'
        [base, @custom_class].compact.join(' ')
      end
    end

    # InputGroupText component for text addons in input groups
    #
    # @example Text addon at start
    #   InputGroupText { "$" }
    #
    # @example Icon addon at end
    #   InputGroupText(position: :end) do
    #     i(class: "fas fa-check")
    #   end
    #
    # @example Styled addon
    #   InputGroupText(class: "bg-blue-50 text-blue-600") { "USD" }
    class InputGroupText < ::Components::Preline::PrelineComponent
      # @param position [Symbol] Position of the addon (:start or :end)
      # @param attrs [Hash] Additional HTML attributes for the addon
      # @option attrs [String] :class CSS classes to add to the addon
      # @option attrs [String] :id HTML ID attribute
      # @option attrs [Hash] :data Data attributes
      def initialize(position: :start, **attrs)
        @position = position
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs
      end

      def view_template(&block)
        code_path 'Renders input group text component'
        span(**@html_attrs, class: text_classes) do
          if block
            code_path 'Renders text addon with content'
            content = capture(&block)
            if content.is_a?(String)
              plain content
            else
              raw(content)
            end
          else
            code_path 'Renders empty text addon'
          end
        end
      end

      private

      def text_classes
        base = 'hs-input-group-text px-4 inline-flex items-center min-w-fit text-sm text-gray-500 bg-gray-50 border border-gray-200'
        position_class = case @position
                         when :end
                           code_path 'Positions addon at end'
                           'rounded-e-md border-s-0'
                         else
                           code_path 'Positions addon at start'
                           'rounded-s-md border-e-0'
                         end

        [base, position_class, @custom_class].compact.join(' ')
      end
    end
  end
end
