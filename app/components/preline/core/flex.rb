# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI flex component for flexible box layouts.
    # Provides easy flexbox utilities with Preline's class naming conventions.
    #
    # @example Basic flex with spacing
    #   render Components::Preline::Flex.new(justify: :between, items: :center) do
    #     span { "Left content" }
    #     span { "Right content" }
    #   end
    #
    # @example Flex with gap and direction
    #   render Components::Preline::Flex.new(
    #     direction: :col,
    #     gap: 4,
    #     class: "p-4"
    #   ) do
    #     # Vertically stacked items with gap
    #   end
    #
    # @example Responsive flex wrap
    #   render Components::Preline::Flex.new(
    #     wrap: true,
    #     justify: :center,
    #     gap: 2
    #   ) do
    #     # Wrapping flex items
    #   end
    class Flex < ::Components::Preline::PrelineComponent
      # Initialize a new Flex component
      #
      # @param direction [Symbol, nil] Flex direction (:row, :col, :row-reverse, :col-reverse)
      # @param wrap [Boolean] Enable flex wrapping
      # @param justify [Symbol, nil] Justify content (:start, :center, :end, :between, :around, :evenly)
      # @param items [Symbol, nil] Align items (:start, :center, :end, :baseline, :stretch)
      # @param gap [Integer, nil] Gap size between items (0-12)
      # @param grow [Boolean] Allow flex items to grow
      # @param shrink [Boolean] Allow flex items to shrink (false prevents shrinking)
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        direction: nil,
        wrap: false,
        justify: nil,
        items: nil,
        gap: nil,
        grow: false,
        shrink: false,
        **attrs
      )
        @direction = direction
        @wrap = wrap
        @justify = justify
        @items = items
        @gap = gap
        @grow = grow
        @shrink = shrink

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @options = attrs.except(:id, :data, :aria, :role, :class)
      end

      def view_template
        code_path 'Renders flex component'
        div(**@html_attrs, **@options, class: build_classes) do
          if block_given?
            code_path 'Renders flex with content'
            yield
          else
            code_path 'Renders empty flex container'
          end
        end
      end

      private

      def build_classes
        classes = ['hs-flex']

        # Direction
        if @direction
          code_path 'Adds flex direction'
          classes << "hs-flex-#{@direction}"
        end

        # Wrap
        if @wrap
          code_path 'Adds flex wrap'
          classes << 'hs-flex-wrap'
        end

        # Justify content
        if @justify
          code_path 'Adds justify content'
          classes << "hs-justify-#{@justify}"
        end

        # Align items
        if @items
          code_path 'Adds align items'
          classes << "hs-items-#{@items}"
        end

        # Gap
        if @gap
          code_path 'Adds gap spacing'
          classes << "hs-gap-#{@gap}"
        end

        # Flex grow/shrink
        if @grow
          code_path 'Adds flex grow'
          classes << 'hs-flex-grow'
        end

        unless @shrink
          code_path 'Prevents flex shrink'
          classes << 'hs-flex-shrink-0'
        end

        [*classes, @custom_class].compact.join(' ')
      end
    end
  end
end
