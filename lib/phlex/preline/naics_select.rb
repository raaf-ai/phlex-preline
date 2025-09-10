# frozen_string_literal: true

module Phlex
  module Preline
    # NaicsSelect - Industry Selection Component
    #
    # A flexible component for selecting industries with support for both
    # single and multiple selection modes.
    #
    # @example Multiple selection (default)
    #   NaicsSelect.new(
    #     field_name: "target_criteria[naics_codes]",
    #     label: "Industries",
    #     selected: positioning.naics_codes,
    #     multiple: true,
    #     max_selections: 10
    #   )
    #
    # @example Single selection
    #   NaicsSelect.new(
    #     field_name: "primary_naics_code",
    #     label: "Primary Industry",
    #     selected: company.primary_naics_code,
    #     multiple: false
    #   )
    #
    class NaicsSelect < Phlex::HTML
      def initialize(
        field_name:,
        label: "Industries",
        selected: [],
        multiple: true,
        searchable: true,
        placeholder: nil,
        required: false,
        hierarchical: true,
        show_hierarchy: true,
        max_selections: nil,
        help_text: nil,
        show_selection_indicators: true,
        show_selected_display: true,
        data_provider: nil,
        **attributes
      )
        @field_name = field_name
        @label = label
        @multiple = multiple
        @selected = normalize_selected_values(selected)
        @searchable = searchable
        @placeholder = placeholder || default_placeholder
        @required = required
        @hierarchical = hierarchical
        @show_hierarchy = show_hierarchy
        @max_selections = multiple ? max_selections : 1
        @help_text = help_text || default_help_text
        @show_selection_indicators = show_selection_indicators
        @show_selected_display = show_selected_display
        @data_provider = data_provider || (defined?(NaicsService) ? NaicsService : nil)
        @attributes = attributes
      end

      def view_template
        div(
          class: "naics-select-wrapper space-y-2",
          data: {
            controller: "naics-select",
            naics_select_multiple_value: @multiple,
            naics_select_hierarchical_value: @hierarchical,
            naics_select_max_selections_value: @max_selections,
            naics_select_field_name_value: @field_name
          }
        ) do
          render_label if @label
          
          # Selected industries container (always rendered, similar to M49Select)
          div(data: { "naics-select-target" => "selectedLabelsContainer" }) do
            if @selected.any?
              render_selection_display
            else
              render_select_button
            end
          end
          
          render_naics_tree
          render_hidden_inputs
          render_help_text if @help_text
        end
      end

      private

      def normalize_selected_values(selected)
        result = case selected
        when Array
          selected.compact.map(&:to_s)
        when String
          selected.present? ? [ selected ] : []
        when nil
          []
        else
          [ selected.to_s ]
        end

        # For single selection mode, only keep the first selected item
        @multiple ? result : result.first(1)
      end

      def render_label
        label(
          for: field_id,
          class: "block text-sm font-medium text-gray-700 dark:text-gray-300"
        ) do
          plain @label
          if @required
            span(class: "text-red-500 ml-1") { "*" }
          end
        end
      end

      def render_search_input
        div(class: "relative") do
          input(
            type: "text",
            placeholder: @placeholder,
            class: "w-full border border-gray-300 rounded-md px-3 py-2 pl-10 focus:outline-none focus:ring-2 focus:ring-blue-500",
            data: {
              naics_select_target: "searchInput",
              action: "input->naics-select#search"
            }
          )
          div(
            class: "absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none"
          ) do
            svg(
              class: "w-4 h-4 text-gray-400",
              fill: "none",
              stroke: "currentColor",
              viewBox: "0 0 24 24"
            ) do |s|
              s.path(
                stroke_linecap: "round",
                stroke_linejoin: "round",
                stroke_width: "2",
                d: "m21 21-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              )
            end
          end
        end
      end

      def render_selection_display
        # Container for selected badges similar to M49Select
        div(class: "mb-4") do
          div(class: "flex flex-wrap gap-2 mb-3") do
            selected_codes = @data_provider ? @data_provider.find_by_codes(@selected) : []
            selected_codes.each do |naics_code|
              render_selected_item(naics_code)
            end

            # Add the "Add more industries" button to the badges row
            if @multiple
              button(
                type: "button",
                class: "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-full hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors",
                data: {
                  action: "click->naics-select#toggleSelector",
                  "naics-select-target" => "toggleButton"
                }
              ) do
                svg(class: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
                  s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 4v16m8-8H4")
                end
                span(data: { "naics-select-target" => "toggleText" }) { "Add more industries" }
              end
            end
          end

          if @multiple && @selected.any?
            p(class: "text-sm text-gray-600") do
              plain "#{@selected.length} #{'industry'.pluralize(@selected.length)} selected"
            end
          end
        end
      end

      def render_selected_item(naics_code)
        render Components::Preline::Badge.new(
          text: naics_code.display_name,
          variant: :primary,
          size: :sm,
          pill: true,
          removable: true,
          data: {
            code: naics_code.code,
            naics_name: naics_code.display_name,
            action: "click->naics-select#removeSelection"
          }
        )
      end

      def render_select_button
        button(
          type: "button",
          class: "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-full hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors",
          data: {
            action: "click->naics-select#toggleSelector",
            "naics-select-target" => "toggleButton"
          }
        ) do
          svg(class: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
            s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 4v16m8-8H4")
          end
          span(data: { "naics-select-target" => "toggleText" }) { "Select industries" }
        end
      end

      def render_naics_tree
        # Hidden NAICS selector (shown when button is clicked)
        div(
          class: "hidden naics-tree border rounded-lg mt-4 p-4 bg-gray-50",
          data: { naics_select_target: "naicsTree" }
        ) do
          # Search input inside the tree container
          render_search_input if @searchable
          
          # Tree content with scroll
          div(class: "max-h-96 overflow-y-auto mt-3") do
            if @hierarchical
              render_hierarchical_tree
            else
              render_flat_list
            end
          end
        end
      end

      def render_hierarchical_tree
        div(class: "p-2") do
          if defined?(NaicsCode)
            NaicsCode.sectors.includes(:children).order(:code).each do |sector|
              render_tree_node(sector, level: 0)
            end
          else
            div(class: "p-4 text-center text-gray-500") do
              plain "NAICS data not available"
            end
          end
        end
      end

      def render_tree_node(naics_code, level: 0)
        # Skip rendering if this item is already selected (shown as labels)
        return if @selected.include?(naics_code.code)

        indent_class = "ml-#{level * 4}"
        has_children = naics_code.children.any?
        # Check if there are any unselected children to expand to
        has_available_children = has_children && naics_code.children.any? { |child| !@selected.include?(child.code) }

        div(class: "naics-node #{indent_class}", data: { code: naics_code.code, level: level }) do
          div(
            class: "flex items-center p-2 hover:bg-gray-50 dark:hover:bg-gray-800 rounded cursor-pointer",
            data: {
              action: "click->naics-select#toggleSelection",
              code: naics_code.code
            }
          ) do
            # Fixed-width container for expansion indicator
            div(class: "w-6 flex justify-center items-center") do
              if has_available_children
                button(
                  type: "button",
                  class: "text-gray-400 hover:text-gray-600 w-4 h-4 flex items-center justify-center",
                  data: {
                    action: "click->naics-select#toggleExpansion",
                    code: naics_code.code
                  }
                ) do
                  svg(
                    class: "w-4 h-4 transform transition-transform",
                    fill: "currentColor",
                    viewBox: "0 0 20 20",
                    data: { naics_select_target: "expandIcon" }
                  ) do |s|
                    s.path(
                      fill_rule: "evenodd",
                      d: "M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z",
                      clip_rule: "evenodd"
                    )
                  end
                end
              end
            end

            # Fixed-width spacer for checkbox area
            if @show_selection_indicators
              div(
                class: "w-6 flex items-center justify-center",
                data: { naics_select_target: "selectionIndicator" }
              ) do
                if @multiple
                  input(
                    type: "checkbox",
                    checked: false,
                    class: "rounded border-gray-300 text-blue-600 focus:ring-blue-500",
                    data: {
                      code: naics_code.code,
                      action: "click->naics-select#toggleSelection"
                    }
                  )
                else
                  input(
                    type: "radio",
                    name: "#{@field_name}_radio",
                    checked: false,
                    class: "border-gray-300 text-blue-600 focus:ring-blue-500",
                    data: {
                      code: naics_code.code,
                      action: "click->naics-select#toggleSelection"
                    }
                  )
                end
              end
            else
              div(class: "w-6") # Fixed spacer where checkbox would be
            end

            # NAICS title only
            div(class: "flex-1") do
              div(class: "text-sm font-medium text-gray-900 dark:text-gray-100") do
                plain naics_code.title
              end
              if naics_code.description.present?
                div(class: "text-xs text-gray-500 dark:text-gray-400 mt-1") do
                  plain truncate(naics_code.description, length: 100)
                end
              end
            end
          end

          # Render children if expanded
          if has_children
            div(
              class: "naics-children",
              style: "display: none;",
              data: {
                naics_select_target: "childrenContainer",
                parent_code: naics_code.code
              }
            ) do
              naics_code.children.order(:code).each do |child|
                render_tree_node(child, level: level + 1)
              end
            end
          end
        end
      end

      def render_flat_list
        div(class: "p-2 space-y-1") do
          if defined?(NaicsCode)
            NaicsCode.all.order(:level, :code).each do |naics_code|
              render_flat_item(naics_code)
            end
          else
            div(class: "p-4 text-center text-gray-500") do
              plain "NAICS data not available"
            end
          end
        end
      end

      def render_flat_item(naics_code)
        is_selected = @selected.include?(naics_code.code)

        div(
          class: "flex items-center p-2 hover:bg-gray-50 dark:hover:bg-gray-800 rounded cursor-pointer",
          data: {
            action: "click->naics-select#toggleSelection",
            code: naics_code.code,
            level: naics_code.level
          }
        ) do
          # Selection checkbox/radio
          div(class: "flex items-center mr-3") do
            if @multiple
              input(
                type: "checkbox",
                checked: is_selected,
                class: "rounded border-gray-300 text-blue-600 focus:ring-blue-500",
                data: {
                  code: naics_code.code,
                  action: "click->naics-select#toggleSelection"
                }
              )
            else
              input(
                type: "radio",
                name: "#{@field_name}_radio",
                checked: is_selected,
                class: "border-gray-300 text-blue-600 focus:ring-blue-500",
                data: {
                  code: naics_code.code,
                  action: "click->naics-select#toggleSelection"
                }
              )
            end
          end

          # NAICS info
          div(class: "flex-1") do
            div(class: "text-sm font-medium text-gray-900 dark:text-gray-100") do
              span(class: "inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-800 mr-2") do
                plain naics_code.level.humanize
              end
              plain naics_code.title
            end
          end
        end
      end

      def render_hidden_inputs
        if @multiple
          @selected.each do |code|
            input(
              type: "hidden",
              name: "#{@field_name}[]",
              value: code,
              data: {
                naics_select_target: "hiddenInput",
                code: code
              }
            )
          end
        else
          input(
            type: "hidden",
            name: @field_name,
            value: @selected.first,
            data: { naics_select_target: "hiddenInput" }
          )
        end
      end

      def render_help_text
        div(class: "text-sm text-gray-500 dark:text-gray-400") do
          plain @help_text
        end
      end

      def field_id
        @field_name.to_s.gsub(/[\[\]]/, "_").squeeze("_").chomp("_")
      end

      def truncate(str, length: 50)
        return str if str.length <= length
        "#{str[0...length]}..."
      end

      def default_placeholder
        if @multiple
          "Search and select industries..."
        else
          "Search and select an industry..."
        end
      end

      def default_help_text
        if @multiple
          return "Select multiple industries that apply to your targeting strategy" if @max_selections.nil?
          "Select up to #{@max_selections} industries that apply to your targeting strategy"
        else
          "Select the primary industry that best describes your target market"
        end
      end

      def selection_display_title
        if @multiple
          count = @selected.count
          return "Selected Industries:" if count != 1
          "Selected Industry:"
        else
          "Selected Industry:"
        end
      end
    end
  end
end