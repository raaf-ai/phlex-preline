# frozen_string_literal: true

module Components
  module Preline
    class LayoutSplitter < ::Components::Preline::PrelineComponent
      def initialize(**attrs)
        @orientation = attrs.delete(:orientation) || :horizontal # :horizontal or :vertical
        @initial_sizes = attrs.delete(:initial_sizes) || [50, 50]
        @min_sizes = attrs.delete(:min_sizes) || [100, 100]
        @resizable = attrs.delete(:resizable) || true
        @gutter_size = attrs.delete(:gutter_size) || 4

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(
          **@html_attrs,
          **@options,
          class: splitter_classes,
          data: splitter_data
        ) do
          yield if block_given?
        end
      end

      private

      def splitter_classes
        base = %w[hs-layout-splitter flex h-full]

        orientation_class = @orientation == :vertical ? 'flex-col' : 'flex-row'

        [base, orientation_class, @custom_class].flatten.compact.join(' ')
      end

      def splitter_data
        {
          'hs-layout-splitter': '',
          'hs-layout-splitter-orientation': @orientation.to_s,
          'hs-layout-splitter-sizes': @initial_sizes.join(','),
          'hs-layout-splitter-min-sizes': @min_sizes.join(','),
          'hs-layout-splitter-resizable': @resizable.to_s,
          'hs-layout-splitter-gutter-size': @gutter_size
        }
      end
    end

    class SplitterPane < ::Components::Preline::PrelineComponent
      def initialize(**attrs)
        @size = attrs.delete(:size)
        @min_size = attrs.delete(:min_size)

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(
          **@html_attrs,
          **@options,
          class: pane_classes,
          data: pane_data
        ) do
          yield if block_given?
        end
      end

      private

      def pane_classes
        base = %w[hs-splitter-pane overflow-auto]

        [base, @custom_class].flatten.compact.join(' ')
      end

      def pane_data
        data = { 'hs-splitter-pane': '' }
        data['hs-splitter-pane-size'] = @size if @size
        data['hs-splitter-pane-min-size'] = @min_size if @min_size
        data
      end
    end

    class SplitterGutter < ::Components::Preline::PrelineComponent
      def initialize(**attrs)
        @orientation = attrs.delete(:orientation) || :horizontal

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(
          **@html_attrs,
          **@options,
          class: gutter_classes,
          data: { 'hs-splitter-gutter': '' }
        )
      end

      private

      def gutter_classes
        base = %w[hs-splitter-gutter relative select-none]

        orientation_classes = if @orientation == :vertical
                                ['h-1', 'cursor-row-resize', 'hover:bg-gray-300']
                              else
                                ['w-1', 'cursor-col-resize', 'hover:bg-gray-300']
                              end

        [base, orientation_classes, 'bg-gray-200', @custom_class].flatten.compact.join(' ')
      end
    end
  end
end
