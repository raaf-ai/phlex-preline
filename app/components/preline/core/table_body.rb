# frozen_string_literal: true

module Components
  module Preline
    # TableBody component for table body
    class TableBody < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders table body component'
        tbody_attrs = component_attributes(additional_classes: tbody_classes)
        tbody(**tbody_attrs) do
          yield if block_given?
        end
      end

      private

      def tbody_classes
        ['hs-table-body divide-y divide-gray-200']
      end
    end
  end
end
