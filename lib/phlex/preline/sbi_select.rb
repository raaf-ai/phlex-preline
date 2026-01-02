# frozen_string_literal: true

module Phlex
  module Preline
    # SbiSelect - SBI Industry Selection Component
    #
    # A flexible component for selecting SBI (Dutch) industries with support for both
    # single and multiple selection modes and multi-language support.
    #
    # @example Multiple selection (default)
    #   SbiSelect.new(
    #     field_name: "target_criteria[sbi_codes]",
    #     label: "Industries",
    #     selected: positioning.sbi_codes,
    #     multiple: true,
    #     language: 'nl'
    #   )
    #
    # @example Single selection
    #   SbiSelect.new(
    #     field_name: "primary_sbi_code",
    #     label: "Primary Industry",
    #     selected: company.primary_sbi_code,
    #     multiple: false,
    #     language: 'en'
    #   )
    #
    class SbiSelect < Phlex::HTML
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
        language: 'nl',
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
        @data_provider = data_provider || (defined?(ClassificationService) ? ClassificationService : nil)
        @language = language
        @attributes = attributes
      end

      def view_template
        div(
          class: "sbi-select-wrapper space-y-2",
          data: {
            controller: "sbi-select",
            sbi_select_multiple_value: @multiple,
            sbi_select_hierarchical_value: @hierarchical,
            sbi_select_max_selections_value: @max_selections,
            sbi_select_field_name_value: @field_name,
            sbi_select_language_value: @language
          }
        ) do
          render_label if @label

          # Selected industries container
          div(data: { "sbi-select-target" => "selectedLabelsContainer" }) do
            if @selected.any?
              render_selection_display
            else
              render_select_button
            end
          end

          render_sbi_tree
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
              sbi_select_target: "searchInput",
              action: "input->sbi-select#search"
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
        div(class: "mb-4") do
          div(class: "flex flex-wrap gap-2 mb-3") do
            selected_codes = @data_provider ? @data_provider.find_sbi_by_codes(@selected) : find_sbi_codes_fallback
            selected_codes.each do |sbi_code|
              render_selected_item(sbi_code)
            end

            # Add the "Add more industries" button to the badges row
            if @multiple
              button(
                type: "button",
                class: "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-full hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors",
                data: {
                  action: "click->sbi-select#toggleSelector",
                  "sbi-select-target" => "toggleButton"
                }
              ) do
                svg(class: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
                  s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 4v16m8-8H4")
                end
                span(data: { "sbi-select-target" => "toggleText" }) { "Add more industries" }
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

      def render_selected_item(sbi_code)
        render Components::Preline::Badge.new(
          text: sbi_code.display_name(@language),
          variant: :primary,
          size: :sm,
          pill: true,
          removable: true,
          data: {
            code: sbi_code.code,
            sbi_name: sbi_code.display_name(@language),
            action: "click->sbi-select#removeSelection"
          }
        )
      end

      def render_select_button
        button(
          type: "button",
          class: "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-full hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors",
          data: {
            action: "click->sbi-select#toggleSelector",
            "sbi-select-target" => "toggleButton"
          }
        ) do
          svg(class: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
            s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 4v16m8-8H4")
          end
          span(data: { "sbi-select-target" => "toggleText" }) { "Select industries" }
        end
      end

      def render_sbi_tree
        div(
          class: "hidden sbi-tree border rounded-lg mt-4 p-4 bg-gray-50",
          data: { sbi_select_target: "sbiTree" }
        ) do
          render_search_input if @searchable

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
          if @data_provider && @data_provider.respond_to?(:get_hierarchical_data)
            hierarchy = @data_provider.get_hierarchical_data(system: :sbi, language: @language)
            hierarchy.each do |section_data|
              render_tree_node_from_data(section_data, level: 0)
            end
          elsif defined?(SbiCode)
            SbiCode.sections.includes(:children).order(:code).each do |section|
              render_tree_node(section, level: 0)
            end
          else
            div(class: "p-4 text-center text-gray-500") do
              plain "SBI data not available"
            end
          end
        end
      end

      def render_tree_node_from_data(node_data, level: 0)
        return if @selected.include?(node_data[:code])

        div(class: "select-none") do
          div(
            class: "flex items-center space-x-2 px-2 py-1 hover:bg-gray-100 cursor-pointer rounded",
            style: "padding-left: #{0.5 + level * 1.5}rem;",
            data: {
              action: "click->sbi-select#selectItem",
              value: node_data[:code],
              title: node_data[:title],
              level: node_data[:level]
            }
          ) do
            if node_data[:children].any?
              span(class: "w-4 h-4 text-gray-400") { "#{level == 0 ? '▶' : '▷'}" }
            else
              span(class: "w-4 h-4") # Spacer
            end

            span(class: "font-medium text-gray-900") { node_data[:code] }
            span(class: "text-gray-600") { node_data[:title] }
          end

          # Recursively render children
          if node_data[:children].any?
            node_data[:children].each do |child_data|
              render_tree_node_from_data(child_data, level: level + 1)
            end
          end
        end
      end

      def render_tree_node(sbi_code, level: 0)
        return if @selected.include?(sbi_code.code)

        indent_class = "ml-#{level * 4}"
        has_children = sbi_code.children.any?
        has_available_children = has_children && sbi_code.children.any? { |child| !@selected.include?(child.code) }

        # Only Class level codes (4-digit) are selectable
        is_selectable = sbi_code.selectable?
        # Determine if this is a category node (not selectable)
        is_category = !is_selectable

        div(class: "sbi-node #{indent_class}", data: { code: sbi_code.code, level: level }) do
          div(
            class: "flex items-center p-2 #{is_selectable ? 'hover:bg-gray-50 dark:hover:bg-gray-800 cursor-pointer' : 'bg-gray-100 dark:bg-gray-700'}#{is_category ? ' font-semibold text-gray-700 dark:text-gray-300' : ''} rounded",
            data: is_selectable ? {
              action: "click->sbi-select#toggleSelection",
              code: sbi_code.code
            } : {}
          ) do
            # Expansion indicator
            div(class: "w-6 flex justify-center items-center") do
              if has_available_children
                button(
                  type: "button",
                  class: "text-gray-400 hover:text-gray-600 w-4 h-4 flex items-center justify-center",
                  data: {
                    action: "click->sbi-select#toggleExpansion",
                    code: sbi_code.code
                  }
                ) do
                  svg(
                    class: "w-4 h-4 transform transition-transform",
                    fill: "currentColor",
                    viewBox: "0 0 20 20",
                    data: { sbi_select_target: "expandIcon" }
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

            # Selection indicator - only for selectable (Class level) codes
            if @show_selection_indicators && is_selectable
              div(
                class: "w-6 flex items-center justify-center",
                data: { sbi_select_target: "selectionIndicator" }
              ) do
                if @multiple
                  input(
                    type: "checkbox",
                    checked: false,
                    class: "rounded border-gray-300 text-blue-600 focus:ring-blue-500",
                    data: {
                      code: sbi_code.code,
                      action: "click->sbi-select#toggleSelection"
                    }
                  )
                else
                  input(
                    type: "radio",
                    name: "#{@field_name}_radio",
                    checked: false,
                    class: "border-gray-300 text-blue-600 focus:ring-blue-500",
                    data: {
                      code: sbi_code.code,
                      action: "click->sbi-select#toggleSelection"
                    }
                  )
                end
              end
            elsif is_category
              # Show category indicator instead of checkbox
              div(class: "w-6 flex items-center justify-center text-gray-400") do
                span(class: "text-xs") { "📁" }
              end
            else
              div(class: "w-6")
            end

            # SBI title and description
            div(class: "flex-1") do
              div(class: "text-sm font-medium text-gray-900 dark:text-gray-100") do
                plain sbi_code.title(@language)
                # Add category label for non-selectable codes
                if is_category
                  span(class: "ml-2 text-xs text-gray-500 italic") do
                    "(category - select specific codes below)"
                  end
                end
              end
              if sbi_code.description(@language).present?
                div(class: "text-xs text-gray-500 dark:text-gray-400 mt-1") do
                  plain truncate(sbi_code.description(@language), length: 100)
                end
              end
            end
          end

          # Render children if expanded
          if has_children
            div(
              class: "sbi-children",
              style: "display: none;",
              data: {
                sbi_select_target: "childrenContainer",
                parent_code: sbi_code.code
              }
            ) do
              sbi_code.children.order(:code).each do |child|
                render_tree_node(child, level: level + 1)
              end
            end
          end
        end
      end

      def render_flat_list
        div(class: "p-2 space-y-1") do
          if @data_provider && @data_provider.respond_to?(:find_by_codes)
            # Get all SBI codes from service - we'll flatten the hierarchy
            hierarchy = @data_provider.get_hierarchical_data(system: :sbi, language: @language)
            flattened_codes = flatten_hierarchy(hierarchy)
            flattened_codes.each do |code_data|
              render_flat_item_from_data(code_data)
            end
          elsif defined?(SbiCode)
            SbiCode.all.order(:level, :code).each do |sbi_code|
              render_flat_item(sbi_code)
            end
          else
            div(class: "p-4 text-center text-gray-500") do
              plain "SBI data not available"
            end
          end
        end
      end

      def render_flat_item(sbi_code)
        is_selected = @selected.include?(sbi_code.code)

        div(
          class: "flex items-center p-2 hover:bg-gray-50 dark:hover:bg-gray-800 rounded cursor-pointer",
          data: {
            action: "click->sbi-select#toggleSelection",
            code: sbi_code.code,
            level: sbi_code.level
          }
        ) do
          div(class: "flex items-center mr-3") do
            if @multiple
              input(
                type: "checkbox",
                checked: is_selected,
                class: "rounded border-gray-300 text-blue-600 focus:ring-blue-500",
                data: {
                  code: sbi_code.code,
                  action: "click->sbi-select#toggleSelection"
                }
              )
            else
              input(
                type: "radio",
                name: "#{@field_name}_radio",
                checked: is_selected,
                class: "border-gray-300 text-blue-600 focus:ring-blue-500",
                data: {
                  code: sbi_code.code,
                  action: "click->sbi-select#toggleSelection"
                }
              )
            end
          end

          div(class: "flex-1") do
            div(class: "text-sm font-medium text-gray-900 dark:text-gray-100") do
              span(class: "inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-800 mr-2") do
                plain sbi_code.level.humanize
              end
              plain sbi_code.title(@language)
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
                sbi_select_target: "hiddenInput",
                code: code
              }
            )
          end
        else
          input(
            type: "hidden",
            name: @field_name,
            value: @selected.first,
            data: { sbi_select_target: "hiddenInput" }
          )
        end
      end

      def render_help_text
        div(class: "text-sm text-gray-500 dark:text-gray-400") do
          plain @help_text
        end
      end

      def flatten_hierarchy(hierarchy)
        flattened = []
        hierarchy.each do |node|
          flattened << node
          flattened.concat(flatten_hierarchy(node[:children])) if node[:children].any?
        end
        flattened
      end

      def render_flat_item_from_data(code_data)
        is_selected = @selected.include?(code_data[:code])

        div(
          class: "flex items-center space-x-2 px-2 py-1 hover:bg-gray-100 cursor-pointer rounded",
          data: {
            action: "click->sbi-select#selectItem",
            value: code_data[:code],
            title: code_data[:title],
            level: code_data[:level]
          }
        ) do
          if @multiple
            input(
              type: "checkbox",
              checked: is_selected,
              class: "form-checkbox h-4 w-4 text-blue-600 transition duration-150 ease-in-out"
            )
          end

          span(class: "font-medium text-gray-900") { code_data[:code] }
          span(class: "text-gray-600") { code_data[:title] }
        end
      end

      def find_sbi_codes_fallback
        if @data_provider && @data_provider.respond_to?(:find_by_codes)
          @data_provider.find_by_codes(@selected, system: :sbi)
        elsif defined?(SbiCode)
          SbiCode.where(code: @selected)
        else
          []
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
        base_text = if @multiple
          if @max_selections.nil?
            "Select multiple industries that apply to your targeting strategy"
          else
            "Select up to #{@max_selections} industries that apply to your targeting strategy"
          end
        else
          "Select the primary industry that best describes your target market"
        end

        # Add explanation about Class-only selection
        "#{base_text}. Only specific 4-digit industry codes can be selected (these match how companies are registered in KVK)."
      end
    end
  end
end