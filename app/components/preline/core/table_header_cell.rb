# frozen_string_literal: true

module Components
  module Preline
    # TableHeaderCell component for table header cells
    class TableHeaderCell < ::Components::Preline::PrelineComponent
      # @param scope [String] Header cell scope ("col" or "row", default: "col")
      # @param attrs [Hash] Additional HTML attributes
      def initialize(scope: 'col', **attrs)
        @scope = validate_inclusion!(scope, 'scope', %w[col row])
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders table header cell component'
        if @scope == 'row'
          code_path 'Renders row scope header cell'
        else
          code_path 'Renders column scope header cell'
        end
        th_attrs = component_attributes(
          additional_classes: th_classes,
          additional_attrs: { scope: @scope }
        )
        th(**th_attrs) do
          yield if block_given?
        end
      end

      private

      def th_classes
        ['hs-table-header-cell px-6 py-3 text-start text-xs font-medium text-gray-500 uppercase']
      end
    end
  end
end
