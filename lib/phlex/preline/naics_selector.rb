# frozen_string_literal: true

module Phlex
  module Preline
    # NaicsSelector - A user-friendly wrapper around NaicsSelect
    #
    # Provides a clean interface for industry selection with:
    # - Selected industry display with clear/change functionality
    # - Toggle button that shows/hides the complex NAICS tree
    # - Single industry selection optimized for primary industry picking
    # - Integration with Stimulus controller for interactive behavior
    #
    # @example Basic usage
    #   NaicsSelector.new(
    #     field_name: "company[primary_naics_code]",
    #     selected_industry: company.primary_naics_code,
    #     data_provider: NaicsService
    #   )
    #
    # @example With custom styling
    #   NaicsSelector.new(
    #     field_name: "user[industry_code]",
    #     selected_industry: user.industry_code,
    #     placeholder_text: "Select your industry",
    #     button_text: { select: "Choose Industry", change: "Change Industry" }
    #   )
    #
    class NaicsSelector < Phlex::HTML
      def initialize(
        field_name:,
        selected_industry: nil,
        data_provider: nil,
        label: "Primary Industry",
        placeholder_text: "No industry selected",
        button_text: { select: "Select Industry", change: "Change Industry" },
        controller_name: "naics-selector",
        **attributes
      )
        @field_name = field_name
        @selected_industry = selected_industry
        @data_provider = data_provider || (defined?(NaicsService) ? NaicsService : nil)
        @label_text = label
        @placeholder_text = placeholder_text
        @button_text = button_text
        @controller_name = controller_name
        @attributes = attributes
      end

      def view_template
        div(class: "space-y-4") do
          render_label if @label_text
          render_selected_industry_display
          render_industry_selector_toggle
        end
      end

      private

      attr_reader :field_name, :selected_industry, :data_provider, :label_text, :placeholder_text,
                  :button_text, :controller_name, :attributes

      def render_label
        label(class: "block text-sm font-medium text-gray-700") do
          plain @label_text
          span(class: "text-red-500 ml-1") { "*" }
        end
      end

      def render_selected_industry_display
        div(class: "mb-4") do
          if selected_industry_code.present?
            render_selected_industry_label
          else
            render_no_selection_message
          end
        end
      end

      def render_selected_industry_label
        return unless selected_industry_data

        div(class: "flex items-center justify-between p-3 bg-blue-50 border border-blue-200 rounded-lg") do
          div(class: "flex-1") do
            div(class: "text-sm font-medium text-blue-900") do
              plain selected_industry_data.title || selected_industry_data.name
            end
            div(class: "text-xs text-blue-700 mt-1") do
              code_text = selected_industry_data.code || selected_industry_code
              level_text = if selected_industry_data.respond_to?(:level)
                             selected_industry_data.level.humanize
                           else
                             "Industry"
                           end
              plain "#{code_text} - #{level_text}"
            end
          end

          button(
            type: "button",
            class: "text-blue-400 hover:text-blue-600 transition-colors",
            data: {
              action: "click->#{controller_name}#clearSelection"
            },
            title: "Change industry"
          ) do
            svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
              s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z")
            end
          end
        end
      end

      def render_no_selection_message
        div(class: "p-3 border-2 border-dashed border-gray-300 rounded-lg text-center") do
          p(class: "text-sm text-gray-500") { @placeholder_text }
        end
      end

      def render_industry_selector_toggle
        div(
          data: {
            controller: controller_name,
            "#{controller_name.underscore.gsub('-', '_')}_selected_code_value" => selected_industry_code,
            "#{controller_name.underscore.gsub('-', '_')}_field_name_value" => field_name
          }
        ) do
          # Toggle button
          render_select_industry_button

          # Hidden NAICS selector (shown when button is clicked)
          div(
            class: "hidden mt-4 p-4 bg-gray-50 rounded-lg border",
            data: { "#{controller_name}_target" => "selectorContainer" }
          ) do
            render NaicsSelect.new(
              field_name: "temp_naics_selection", # Temporary field name
              label: nil,
              selected: selected_industry_code,
              multiple: false,
              searchable: true,
              hierarchical: true,
              show_selected_display: false, # Hide the built-in display since we have our own
              required: false,
              data_provider: data_provider
            )
          end

          # Hidden input for the selected industry
          input(
            type: "hidden",
            name: field_name,
            value: selected_industry_code,
            data: {
              "#{controller_name}_target" => "hiddenField"
            }
          )
        end
      end

      def render_select_industry_button
        button(
          type: "button",
          class: "w-full flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-md hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors",
          data: {
            action: "click->#{controller_name}#toggleSelector",
            "#{controller_name}_target" => "toggleButton"
          }
        ) do
          svg(class: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
            s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z")
          end
          span(data: { "#{controller_name}_target" => "toggleText" }) { toggle_button_text }
        end
      end

      def toggle_button_text
        if selected_industry_code.present?
          @button_text[:change]
        else
          @button_text[:select]
        end
      end

      def selected_industry_code
        case selected_industry
        when String, Integer
          selected_industry.to_s
        when NilClass
          nil
        else
          # Assume it's an object with a code or id method
          if selected_industry.respond_to?(:code)
            selected_industry.code.to_s
          elsif selected_industry.respond_to?(:id)
            selected_industry.id.to_s
          else
            selected_industry.to_s
          end
        end
      end

      def selected_industry_data
        return nil unless selected_industry_code.present? && data_provider

        @selected_industry_data ||= begin
          if data_provider.respond_to?(:find_by_code)
            data_provider.find_by_code(selected_industry_code)
          elsif data_provider.respond_to?(:find_by_codes)
            codes = data_provider.find_by_codes([selected_industry_code])
            codes.first
          elsif defined?(NaicsCode)
            NaicsCode.find_by(code: selected_industry_code)
          else
            nil
          end
        end
      end
    end
  end
end