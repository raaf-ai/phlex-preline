# frozen_string_literal: true

module Components
  module Preline
    # TableHead component for table headers
    class TableHead < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders table head component'
        thead_attrs = component_attributes(additional_classes: thead_classes)
        thead(**thead_attrs) do
          yield if block_given?
        end
      end

      private

      def thead_classes
        ['hs-table-head']
      end
    end
  end
end
