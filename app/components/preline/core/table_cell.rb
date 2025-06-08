# frozen_string_literal: true

module Components
  module Preline
    # TableCell component for table data cells
    class TableCell < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders table cell component'
        td_attrs = component_attributes(additional_classes: td_classes)
        td(**td_attrs) do
          yield if block_given?
        end
      end

      private

      def td_classes
        ['hs-table-cell px-6 py-4 whitespace-nowrap text-sm text-gray-800']
      end
    end
  end
end
