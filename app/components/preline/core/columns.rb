# frozen_string_literal: true

module Components
  module Preline
    # Columns component for creating multi-column layouts
    #
    # The Columns component provides a CSS columns-based layout system that automatically
    # flows content into multiple columns. Unlike grid or flexbox, content flows naturally
    # from one column to the next, making it ideal for text-heavy layouts, lists, or
    # card-based designs where items should fill columns vertically before moving to the next.
    #
    # @example Basic two-column layout
    #   Columns do
    #     p { "This content will flow into columns..." }
    #     p { "And continue in the next column..." }
    #   end
    #
    # @example Three columns with custom gap
    #   Columns(cols: 3, gap: 6) do
    #     (1..9).each do |i|
    #       Card(class: "mb-4") do
    #         h3 { "Item #{i}" }
    #         p { "Content for item #{i}" }
    #       end
    #     end
    #   end
    #
    # @example Responsive columns
    #   Columns(
    #     cols: 1,
    #     responsive: { md: 2, lg: 3, xl: 4 }
    #   ) do
    #     # Content adapts from 1 column on mobile to 4 on extra large screens
    #     render_article_list
    #   end
    #
    # @example With column breaks
    #   Columns(cols: 2) do
    #     h3 { "Section 1" }
    #     p { "Content..." }
    #
    #     ColumnBreak() # Force next content to start in new column
    #
    #     h3 { "Section 2" }
    #     p { "More content..." }
    #   end
    #
    # @example Gallery-style layout
    #   Columns(cols: 4, gap: 4, class: "my-gallery") do
    #     images.each do |image|
    #       Image(
    #         src: image.url,
    #         alt: image.alt_text,
    #         class: "mb-4 rounded-lg"
    #       )
    #     end
    #   end
    class Columns < ::Components::Preline::PrelineComponent
      # @param cols [Integer] Number of columns (1-12)
      # @param gap [Integer] Gap between columns in Tailwind spacing units (0-12)
      # @param responsive [Hash] Responsive column counts by breakpoint
      # @option responsive [Integer] :sm Columns on small screens
      # @option responsive [Integer] :md Columns on medium screens
      # @option responsive [Integer] :lg Columns on large screens
      # @option responsive [Integer] :xl Columns on extra large screens
      # @option responsive [Integer] :2xl Columns on 2x large screens
      # @param attrs [Hash] Additional HTML attributes
      def initialize(cols: 2, gap: 4, responsive: {}, **attrs)
        @cols = cols
        @gap = gap
        @responsive = responsive

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders columns component'
        column_attrs = component_attributes(additional_classes: column_classes)
        div(**column_attrs) do
          if block_given?
            code_path 'Renders columns with content'
            yield(self)
          else
            code_path 'Renders empty columns'
          end
        end
      end

      private

      def column_classes
        base = ['hs-columns']

        # Base columns
        base << "columns-#{@cols}"

        # Responsive columns
        if @responsive.any?
          code_path 'Adds responsive columns'
          @responsive.each do |breakpoint, cols|
            base << "#{breakpoint}:columns-#{cols}"
          end
        end

        # Gap
        if @gap&.positive?
          code_path 'Adds column gap'
          base << "gap-#{@gap}"
        end

        base
      end
    end

    # ColumnBreak component for forcing content to start in a new column
    #
    # Use ColumnBreak within a Columns component to control where column breaks occur.
    # This is useful for ensuring headers or new sections start at the top of a column.
    #
    # @example Basic usage
    #   Columns(cols: 3) do
    #     h2 { "Chapter 1" }
    #     p { "Content..." }
    #
    #     ColumnBreak()
    #
    #     h2 { "Chapter 2" }
    #     p { "More content..." }
    #   end
    #
    # @example Conditional column break
    #   Columns(cols: 2) do
    #     items.each_with_index do |item, index|
    #       render_item(item)
    #       ColumnBreak() if index == items.size / 2 - 1
    #     end
    #   end
    class ColumnBreak < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders column break'
        break_attrs = component_attributes(additional_classes: [break_classes])
        div(**break_attrs)
      end

      private

      def break_classes
        'break-after-column'
      end
    end
  end
end
