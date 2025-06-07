# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI grid component for creating responsive grid layouts.
    # Supports responsive column counts and customizable gaps.
    #
    # @example Basic responsive grid
    #   render Components::Preline::Grid.new(cols: 1, md: 2, lg: 3) do
    #     # Grid items
    #   end
    #
    # @example Grid with gap and alignment
    #   render Components::Preline::Grid.new(
    #     cols: 4,
    #     gap: 6,
    #     align_items: :center,
    #     class: "p-4"
    #   ) do
    #     # 4-column grid with centered items
    #   end
    #
    # @example Fully responsive grid
    #   render Components::Preline::Grid.new(
    #     cols: 1,
    #     sm: 2,
    #     md: 3,
    #     lg: 4,
    #     xl: 6,
    #     gap: 4
    #   ) do
    #     # Grid that adapts to all screen sizes
    #   end
    class Grid < ::Components::Preline::PrelineComponent
      # Initialize a new Grid component
      #
      # @param cols [Integer] Base number of columns (mobile-first)
      # @param sm [Integer, nil] Columns on small screens and up
      # @param md [Integer, nil] Columns on medium screens and up
      # @param lg [Integer, nil] Columns on large screens and up
      # @param xl [Integer, nil] Columns on extra large screens and up
      # @param gap [Integer] Gap size between grid items (0-12)
      # @param align_items [Symbol, nil] Vertical alignment (:start, :center, :end, :baseline, :stretch)
      # @param justify_items [Symbol, nil] Horizontal alignment (:start, :center, :end, :stretch)
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        cols: 1,
        sm: nil,
        md: nil,
        lg: nil,
        xl: nil,
        gap: 4,
        align_items: nil,
        justify_items: nil,
        **attrs
      )
        @cols = cols
        @sm = sm
        @md = md
        @lg = lg
        @xl = xl
        @gap = gap
        @align_items = align_items
        @justify_items = justify_items

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @options = attrs.except(:id, :data, :aria, :role, :class)
      end

      def view_template
        code_path 'Renders grid component'
        div(**@html_attrs, **@options, class: build_classes) do
          if block_given?
            code_path 'Renders grid with content'
            yield
          else
            code_path 'Renders empty grid container'
          end
        end
      end

      private

      def build_classes
        classes = ['hs-grid']

        # Base columns
        classes << "hs-grid-cols-#{@cols}"

        # Responsive columns
        if @sm
          code_path 'Adds sm breakpoint columns'
          classes << "sm:hs-grid-cols-#{@sm}"
        end

        if @md
          code_path 'Adds md breakpoint columns'
          classes << "md:hs-grid-cols-#{@md}"
        end

        if @lg
          code_path 'Adds lg breakpoint columns'
          classes << "lg:hs-grid-cols-#{@lg}"
        end

        if @xl
          code_path 'Adds xl breakpoint columns'
          classes << "xl:hs-grid-cols-#{@xl}"
        end

        # Gap
        if @gap && @gap != 0
          code_path 'Adds grid gap'
          classes << "hs-gap-#{@gap}"
        end

        # Alignment
        if @align_items
          code_path 'Adds align items'
          classes << "hs-items-#{@align_items}"
        end

        if @justify_items
          code_path 'Adds justify items'
          classes << "hs-justify-items-#{@justify_items}"
        end

        [*classes, @custom_class].compact.join(' ')
      end
    end
  end
end
