# frozen_string_literal: true

module Phlex
  module Preline
    # RegionSelector - A user-friendly wrapper around M49Select
    #
    # Provides a clean interface for region selection with:
    # - Selected region display with clear/change functionality
    # - Toggle button that shows/hides the complex M49Select tree
    # - Single region selection optimized for country/region picking
    # - Integration with Stimulus controller for interactive behavior
    #
    # @example Basic usage
    #   RegionSelector.new(
    #     field_name: "company[m49_region_id]",
    #     selected_region: company.m49_region_id,
    #     data_provider: M49Service
    #   )
    #
    # @example With custom styling
    #   RegionSelector.new(
    #     field_name: "user[country_id]",
    #     selected_region: user.country_id,
    #     placeholder_text: "Select your country",
    #     button_text: { select: "Choose Country", change: "Change Country" }
    #   )
    #
    class RegionSelector < Phlex::HTML
      def initialize(
        field_name:,
        selected_region: nil,
        data_provider: nil,
        placeholder_text: "No country/region selected",
        button_text: { select: "Select Country/Region", change: "Change Country/Region" },
        include_countries: true,
        include_regions: false,
        controller_name: "region-selector",
        **attributes
      )
        @field_name = field_name
        @selected_region = selected_region
        @data_provider = data_provider || (defined?(M49Service) ? M49Service : nil)
        @placeholder_text = placeholder_text
        @button_text = button_text
        @include_countries = include_countries
        @include_regions = include_regions  
        @controller_name = controller_name
        @attributes = attributes
      end

      def view_template
        div(class: "space-y-4") do
          render_selected_region_display
          render_region_selector_toggle
        end
      end

      private

      attr_reader :field_name, :selected_region, :data_provider, :placeholder_text, 
                  :button_text, :include_countries, :include_regions, :controller_name, :attributes

      def render_selected_region_display
        div(class: "mb-4") do
          if selected_region_id.present?
            render_selected_region_label
          else
            render_no_selection_message
          end
        end
      end

      def render_selected_region_label
        return unless selected_region_data

        div(class: "flex items-center justify-between p-3 bg-green-50 border border-green-200 rounded-lg") do
          div(class: "flex-1") do
            div(class: "text-sm font-medium text-green-900") do
              plain selected_region_data.name
            end
            if selected_region_data.respond_to?(:full_path) && selected_region_data.full_path.present?
              div(class: "text-xs text-green-700 mt-1") do
                plain selected_region_data.full_path
              end
            end
          end

          button(
            type: "button",
            class: "text-green-400 hover:text-green-600 transition-colors",
            data: {
              action: "click->#{controller_name}#clearSelection"
            },
            title: "Change region"
          ) do
            svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
              s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z")
            end
          end
        end
      end

      def render_no_selection_message
        div(class: "p-3 border-2 border-dashed border-gray-300 rounded-lg text-center") do
          p(class: "text-sm text-gray-500") { placeholder_text }
        end
      end

      def render_region_selector_toggle
        div(
          data: {
            controller: controller_name,
            "#{controller_name.underscore.gsub('-', '_')}_selected_id_value" => selected_region_id,
            "#{controller_name.underscore.gsub('-', '_')}_field_name_value" => field_name
          }
        ) do
          # Toggle button
          render_select_region_button

          # Hidden M49 selector (shown when button is clicked)
          div(
            class: "hidden mt-4 p-4 bg-gray-50 rounded-lg border",
            data: { "#{controller_name}_target" => "selectorContainer" }
          ) do
            render M49Select.new(
              field_name: "temp_m49_selection", # Temporary field name
              label: nil,
              selected_regions: selected_region_id,
              multiple: false,
              include_countries: include_countries,
              include_regions: include_regions,
              required: false,
              data_provider: data_provider
            )
          end

          # Hidden input for the selected region
          input(
            type: "hidden",
            name: field_name,
            value: selected_region_id,
            data: {
              "#{controller_name}_target" => "hiddenField"
            }
          )
        end
      end

      def render_select_region_button
        button(
          type: "button",
          class: "w-full flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium text-green-600 bg-white border border-green-300 rounded-md hover:bg-green-50 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition-colors",
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
        if selected_region_id.present?
          button_text[:change]
        else
          button_text[:select]
        end
      end

      def selected_region_id
        case selected_region
        when String, Integer
          selected_region.to_s
        when NilClass
          nil
        else
          # Assume it's an object with an id method
          selected_region.respond_to?(:id) ? selected_region.id.to_s : selected_region.to_s
        end
      end

      def selected_region_data
        return nil unless selected_region_id.present? && data_provider

        @selected_region_data ||= begin
          if data_provider.respond_to?(:find_by_code)
            data_provider.find_by_code(selected_region_id)
          elsif data_provider.respond_to?(:find_regions)
            regions = data_provider.find_regions([selected_region_id])
            regions.first
          elsif defined?(M49Region)
            M49Region.find_by(id: selected_region_id)
          else
            nil
          end
        end
      end
    end
  end
end