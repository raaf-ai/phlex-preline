# frozen_string_literal: true

module Components
  module Preline
    # TableRow component for table rows
    class TableRow < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders table row component'
        tr_attrs = component_attributes(additional_classes: tr_classes)
        tr(**tr_attrs) do
          yield if block_given?
        end
      end

      private

      def tr_classes
        []
      end
    end
  end
end
