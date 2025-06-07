# frozen_string_literal: true

module Components
  module Preline
    # Table component for displaying tabular data
    #
    # @example Basic table
    #   render Components::Preline::Table.new do
    #     TableHead do
    #       TableRow do
    #         TableHeaderCell { "Name" }
    #         TableHeaderCell { "Email" }
    #         TableHeaderCell { "Status" }
    #       end
    #     end
    #     TableBody do
    #       @users.each do |user|
    #         TableRow do
    #           TableCell { user.name }
    #           TableCell { user.email }
    #           TableCell { user.status }
    #         end
    #       end
    #     end
    #   end
    #
    # @example With styling options
    #   render Components::Preline::Table.new(
    #     striped: true,
    #     hoverable: true,
    #     size: :sm
    #   ) do
    #     # Table content
    #   end
    class Table < ::Components::Preline::PrelineComponent
      # @param hoverable [Boolean] Whether rows show hover state (default: false)
      # @param striped [Boolean] Whether to show striped rows (default: false)
      # @param size [Symbol] Table size (:sm, :default, :lg)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(hoverable: false, striped: false, size: :default, **attrs)
        # Validate inputs
        @hoverable = validate_boolean!(hoverable, 'hoverable')
        @striped = validate_boolean!(striped, 'striped')
        @size = validate_inclusion!(size, 'size', %i[sm default lg])

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders table component'
        div(class: 'flex flex-col') do
          div(class: '-m-1.5 overflow-x-auto') do
            div(class: 'p-1.5 min-w-full inline-block align-middle') do
              div(class: 'overflow-hidden') do
                table_attrs = component_attributes(additional_classes: table_classes)
                table(**table_attrs) do
                  yield if block_given?
                end
              end
            end
          end
        end
      end

      private

      def table_classes
        base = 'hs-table min-w-full divide-y divide-gray-200'

        hover = if @hoverable
                  code_path 'Renders hoverable table rows'
                  'hs-table-hover'
                else
                  ''
                end

        stripe = if @striped
                   code_path 'Renders striped table rows'
                   'hs-table-striped'
                 else
                   ''
                 end

        size_class = case @size
                     when :sm
                       code_path 'Renders small size table'
                       'hs-table-sm'
                     when :lg
                       code_path 'Renders large size table'
                       'hs-table-lg'
                     else
                       code_path 'Renders default size table'
                       ''
                     end

        [base, hover, stripe, size_class].compact
      end
    end

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
