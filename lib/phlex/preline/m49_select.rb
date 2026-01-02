# frozen_string_literal: true

module Phlex
  module Preline
    # M49Select - Component for selecting UN M49 regions with hierarchical structure
    #
    # A flexible component for selecting UN M49 regions with support for both
    # single and multiple selection modes.
    #
    # @example Multiple selection (default)
    #   M49Select(
    #     field_name: "product_positioning[m49_region_ids]",
    #     label: "Target Regions",
    #     selected_regions: positioning.m49_region_ids,
    #     multiple: true,
    #     max_selections: 10
    #   )
    #
    # @example Single selection
    #   M49Select(
    #     field_name: "company[primary_region_id]",
    #     label: "Primary Market Region",
    #     selected_regions: company.primary_region_id,
    #     multiple: false
    #   )
    #
    # Features:
    # - Hierarchical region display with proper indentation
    # - Search functionality across region names and codes
    # - Single or multiple selection modes
    # - Region type icons and labels
    # - Expandable/collapsible tree structure
    #
    class M49Select < Phlex::HTML
      def initialize(
        field_name:,
        selected_regions: [],
        label: nil,
        multiple: true,
        searchable: true,
        placeholder: nil,
        required: false,
        help_text: nil,
        include_countries: true,
        include_regions: true,
        active_only: true,
        max_selections: nil,
        data_provider: nil,
        **attributes
      )
        @field_name = field_name
        @multiple = multiple
        @selected_regions = normalize_selected_values(selected_regions)
        @label = label
        @searchable = searchable
        @placeholder = placeholder || default_placeholder
        @required = required
        @help_text = help_text
        @include_countries = include_countries
        @include_regions = include_regions
        @active_only = active_only
        @max_selections = max_selections
        @attributes = attributes
        @data_provider = data_provider || default_data_provider

        @hierarchical_data = load_hierarchical_data
      end

      def view_template
        div(class: "space-y-4") do
          render_label if @label
          render_region_selector_toggle
          render_help_text if @help_text
        end
      end

      private

      attr_reader :field_name, :multiple, :selected_regions, :searchable,
                  :placeholder, :required, :help_text, :include_countries,
                  :include_regions, :active_only, :max_selections, :hierarchical_data

      def render_label
        div(class: "block text-sm font-medium text-gray-700 mb-4") do
          plain @label
          if @required
            span(class: "text-red-500 ml-1") { "*" }
          end
        end
      end

      def render_region_selector_toggle
        div(
          data: {
            controller: "m49-select",
            m49_select_selected_regions_value: @selected_regions.to_json,
            m49_select_selected_regions_data_value: selected_region_data.to_json,
            m49_select_hierarchical_data_value: begin
              if defined?(Rails) && Rails.respond_to?(:logger)
                Rails.logger.debug "About to serialize hierarchical_data: #{hierarchical_data.length} regions"
                Rails.logger.debug "hierarchical_data class: #{hierarchical_data.class.name}"
                if hierarchical_data.first
                  Rails.logger.debug "First region for JSON: #{hierarchical_data.first[:name]} has #{hierarchical_data.first[:children]&.length || 0} children"
                end
              end
              hierarchical_data.to_json
            end,
            m49_select_field_name_value: @field_name,
            m49_select_multiple_value: @multiple
          }
        ) do
          # Selected regions container (always rendered, JavaScript will manage)
          div(data: { "m49-select-target" => "selectedLabelsContainer" }) do
            if @selected_regions.any?
              render_selected_regions_labels_placeholder
            else
              render_select_button
            end
          end

          # Hidden M49 selector (shown when button is clicked)
          div(
            class: "hidden mt-4 p-4 bg-gray-50 rounded-lg border",
            data: { "m49-select-target" => "selectorContainer" }
          ) do
            render_search_input
            render_options_dropdown
          end

          # Hidden inputs container
          div(data: { "m49-select-target" => "hiddenInputs" }) do
            @selected_regions.each_with_index do |region_id, index|
              # Only set required on first hidden input to avoid multiple validation messages
              input_attrs = {
                type: "hidden",
                name: @field_name,
                value: region_id,
                data: {
                  "m49-select-target" => "hiddenField",
                  region_id: region_id
                }
              }
              # Add required attribute to first hidden input only
              input_attrs[:required] = true if @required && index == 0

              input(**input_attrs)
            end

            # If no regions selected yet but field is required, add a dummy hidden input
            # with required attribute so FormValidator can detect it
            if @selected_regions.empty? && @required
              input(
                type: "hidden",
                name: @field_name,
                value: "",
                required: true,
                data: {
                  "m49-select-target" => "hiddenField"
                }
              )
            end
          end
        end
      end

      def render_selected_regions_labels_placeholder
        # Placeholder that JavaScript will replace with dynamic labels
        div(class: "mb-4") do
          div(class: "flex flex-wrap gap-2 mb-3") do
            selected_region_data.each do |region|
              render_region_label(region)
            end

            # Add the "Add more regions" button to the labels row
            if @multiple
              button(
                type: "button",
                class: "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-full hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors",
                data: {
                  action: "click->m49-select#toggleSelector",
                  "m49-select-target" => "toggleButton"
                }
              ) do
                svg(class: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
                  s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 4v16m8-8H4")
                end
                span(data: { "m49-select-target" => "toggleText" }) { "Add more regions" }
              end
            end
          end

          if @multiple
            p(class: "text-sm text-gray-600") do
              count = @selected_regions.length
              plural = count == 1 ? "region" : "regions"
              plain "#{count} #{plural} selected"
            end
          end
        end
      end

      def render_region_label(region)
        render Components::Preline::Badge.new(
          text: region[:display_name],
          variant: :primary,
          size: :sm,
          pill: true,
          removable: true,
          data: {
            region_id: region[:id],
            region_name: region[:name],
            action: "click->m49-select#removeRegion"
          }
        )
      end

      def render_select_button
        button(
          type: "button",
          class: "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-full hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors",
          data: {
            action: "click->m49-select#toggleSelector",
            "m49-select-target" => "toggleButton"
          }
        ) do
          svg(class: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
            s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 4v16m8-8H4")
          end
          span(data: { "m49-select-target" => "toggleText" }) { toggle_button_text }
        end
      end

      def toggle_button_text
        if @selected_regions.any?
          @multiple ? "Add more regions" : "Change region"
        else
          @multiple ? "Select regions" : "Select region"
        end
      end

      def render_search_input
        div(class: "relative mb-2") do
          input(
            type: "text",
            placeholder: "Search regions...",
            class: "w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500",
            data: {
              m49_select_target: "searchInput"
            }
          )

          # Search icon
          div(class: "absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none") do
            svg(
              class: "w-4 h-4 text-gray-400",
              fill: "none",
              stroke: "currentColor",
              viewBox: "0 0 24 24"
            ) do
              raw('<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m21 21-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>'.html_safe)
            end
          end
        end
      end


      def render_options_dropdown
        div(
          class: "border rounded-lg max-h-96 overflow-y-auto",
          data: { m49_select_target: "dropdown" }
        ) do
          render_hierarchical_options
        end
      end

      def render_hierarchical_options
        hierarchical_data.each do |region_data|
          render_option_item(region_data, 0)
        end
      end

      def render_option_item(region_data, depth = 0)
        return unless should_include_region?(region_data)
        # Skip rendering if this region is already selected (shown as labels)
        return if selected_regions.include?(region_data[:id].to_s)

        div(
          class: option_item_classes(region_data),
          data: {
            action: "click->m49-select#selectRegion",
            region_id: region_data[:id],
            region_type: region_data[:region_type],
            searchable: region_data[:name].downcase
          }
        ) do
          div(class: "flex items-center gap-2") do
            # Indentation for hierarchy
            div(style: "margin-left: #{depth * 1.5}rem") do
              div(class: "flex items-center gap-2") do
                render_region_icon(region_data[:region_type])
                span(class: "text-sm") { region_data[:name] }

                if region_data[:children]&.any?
                  span(class: "text-xs text-gray-400") { "(#{region_data[:children].length} children)" }
                end
              end
            end
          end
        end

        # Render children recursively
        if region_data[:children]&.any?
          region_data[:children].each do |child_data|
            render_option_item(child_data, depth + 1)
          end
        end
      end

      def render_region_icon(region_type)
        icon_class = case region_type
        when "world"
                      "w-4 h-4 text-purple-600"
        when "continental_region"
                      "w-4 h-4 text-green-600"
        when "geographical_subregion"
                      "w-4 h-4 text-blue-600"
        when "country", "territory"
                      "w-4 h-4 text-orange-600"
        else
                      "w-4 h-4 text-gray-400"
        end

        svg(class: icon_class, fill: "currentColor", viewBox: "0 0 20 20") do
          case region_type
          when "world"
            raw('<circle cx="10" cy="10" r="8"></circle>'.html_safe)
          when "continental_region"
            raw('<path d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z"></path>'.html_safe)
          when "geographical_subregion"
            raw('<path d="M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z"></path>'.html_safe)
          else
            raw('<path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z"></path>'.html_safe)
          end
        end
      end

      def render_hidden_inputs
        # Empty container - JavaScript will populate with hidden inputs
        # to avoid server/client duplication issues
        div(data: { m49_select_target: "hiddenInputs" })
      end

      def render_help_text
        p(class: "mt-1 text-sm text-gray-500") { plain @help_text }
      end

      # Helper methods

      def normalize_selected_values(selected)
        if multiple
          Array(selected).map(&:to_s).compact.uniq
        else
          selected.present? ? [ selected.to_s ] : []
        end
      end

      def default_placeholder
        if multiple
          "Select regions..."
        else
          "Select a region..."
        end
      end


      def should_include_region?(region_data)
        case region_data[:region_type]
        when "country", "territory"
          include_countries
        else
          include_regions
        end
      end

      def option_item_classes(region_data)
        "px-3 py-2 cursor-pointer hover:bg-gray-50 border-b border-gray-100"
      end

      def children_count(region_data)
        region_data[:children]&.length || 0
      end


      def selected_region_data
        @selected_region_data ||= begin
          return [] if selected_regions.empty?

          # Fetch selected regions using data provider
          regions = @data_provider.find_regions(selected_regions)

          regions.map do |region|
            {
              id: region.id,
              name: region.name,
              display_name: region.display_name,
              region_type: region.region_type,
              code: region.code,
              iso_alpha2: region.iso_alpha2
            }
          end
        end
      end

      def load_hierarchical_data
        # Use the data provider to get hierarchical data
        result = @data_provider.hierarchical_list(
          include_countries: include_countries,
          active_only: active_only
        )

        # Log the structure for debugging
        puts "M49Select load_hierarchical_data: #{result.length} top-level regions"
        if result.first
          puts "First region in M49Select: #{result.first[:name]} has #{result.first[:children]&.length || 0} children"
          puts "First region children types: #{result.first[:children]&.map { |c| c[:region_type] }&.uniq}"
        end

        result
      end

      def default_data_provider
        # Default to using the host application's M49Service if available
        if defined?(::M49Service)
          ::M49Service
        else
          raise "No data provider specified and M49Service not available. Please provide a data_provider parameter."
        end
      end
    end
  end
end
