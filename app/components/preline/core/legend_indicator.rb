# frozen_string_literal: true

module Components
  module Preline
    # LegendIndicator component for displaying color-coded legend items
    # Useful for charts, graphs, or any visualization that needs a color legend
    #
    # @example Basic legend with predefined colors
    #   LegendIndicator(items: [
    #     { label: "Active", color: :green, value: "85%" },
    #     { label: "Pending", color: :yellow, value: "10%" },
    #     { label: "Inactive", color: :red, value: "5%" }
    #   ])
    #
    # @example Legend with custom hex colors
    #   LegendIndicator(items: [
    #     { label: "Revenue", color: "#4F46E5" },
    #     { label: "Expenses", color: "#EF4444" },
    #     { label: "Profit", color: "#10B981" }
    #   ])
    #
    # @example Simple legend without values
    #   LegendIndicator(items: [
    #     { label: "Category A", color: :blue },
    #     { label: "Category B", color: :purple },
    #     { label: "Category C", color: :gray }
    #   ])
    #
    # @example Legend with additional content
    #   LegendIndicator(items: [
    #     { label: "Completed", color: :green }
    #   ]) do
    #     button(class: "text-sm text-blue-600") { "View all" }
    #   end
    class LegendIndicator < ::Components::Preline::PrelineComponent
      # @param items [Array<Hash>] Array of legend items with :label, :color, and optional :value
      # @option items [String] :label The text label for the legend item
      # @option items [Symbol, String] :color Color as symbol (:blue, :green, etc.) or hex string
      # @option items [String] :value Optional value to display after the label
      # @param attrs [Hash] Additional HTML attributes and options
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :* Any other HTML attributes
      def initialize(items: [], **attrs)
        @items = items
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.except(:items)
        @options = attrs.slice(:items)
      end

      def view_template
        div(**html_attrs, class: legend_classes) do
          items.each do |item|
            render_legend_item(item)
          end
          yield if block_given?
        end
      end

      private

      attr_reader :items, :custom_class, :html_attrs, :options

      def legend_classes
        base = 'hs-legend-indicator flex flex-wrap gap-4'
        [base, custom_class].compact.join(' ')
      end

      def render_legend_item(item)
        div(class: 'hs-legend-item flex items-center gap-x-2') do
          div(class: indicator_classes(item[:color]))
          span(class: 'text-sm text-gray-600') { item[:label] }
          span(class: 'text-sm font-medium text-gray-900') { item[:value] } if item[:value]
        end
      end

      def indicator_classes(color)
        base = 'hs-legend-indicator-dot size-3 rounded-full'
        color_class = case color
                      when :blue then 'bg-blue-600'
                      when :green then 'bg-green-600'
                      when :red then 'bg-red-600'
                      when :yellow then 'bg-yellow-600'
                      when :purple then 'bg-purple-600'
                      when :gray then 'bg-gray-600'
                      else color.to_s.start_with?('#') ? '' : 'bg-gray-400'
                      end

        if color.to_s.start_with?('#')
          "#{base} style='background-color: #{color}'"
        else
          [base, color_class].compact.join(' ')
        end
      end
    end
  end
end
