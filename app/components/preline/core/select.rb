# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI select component for dropdown form fields.
    # Integrates with Rails form builders and supports validation states.
    #
    # @example Basic select with options
    #   render Components::Preline::Select.new(
    #     form: form,
    #     field: :country,
    #     options: ["USA", "Canada", "Mexico"],
    #     label: "Country",
    #     prompt: "Select a country"
    #   )
    #
    # @example Select with grouped options
    #   render Components::Preline::Select.new(
    #     form: form,
    #     field: :city,
    #     options: {
    #       "California" => ["Los Angeles", "San Francisco"],
    #       "Texas" => ["Houston", "Dallas"]
    #     },
    #     label: "City",
    #     required: true
    #   )
    #
    # @example Multiple select with error
    #   render Components::Preline::Select.new(
    #     form: form,
    #     field: :tags,
    #     options: [["Ruby", "ruby"], ["Python", "python"], ["JavaScript", "js"]],
    #     multiple: true,
    #     label: "Programming Languages",
    #     help_text: "Select all that apply",
    #     error: @user.errors[:tags].first
    #   )
    class Select < ::Components::Preline::PrelineComponent
      # Initialize a new Select component
      #
      # @param form [ActionView::Helpers::FormBuilder] Rails form builder instance
      # @param field [Symbol] Form field name
      # @param options [Array, Hash] Select options (array, hash for grouped options, or array of arrays for value/text pairs)
      # @param label [String, nil] Field label text
      # @param prompt [String, nil] Prompt text for unselected state
      # @param selected [String, Array, nil] Pre-selected value(s)
      # @param multiple [Boolean] Allow multiple selections
      # @param required [Boolean] Mark field as required
      # @param disabled [Boolean] Disable the select
      # @param help_text [String, nil] Help text displayed below the select
      # @param error [String, nil] Error message to display
      # @param class [String] Additional CSS classes for the wrapper
      # @param select_class [String] Additional CSS classes for the select element
      # @param wrapper_class [String] Additional CSS classes for the wrapper
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        form:,
        field:,
        options:,
        label: nil,
        prompt: nil,
        selected: nil,
        multiple: false,
        required: false,
        disabled: false,
        help_text: nil,
        error: nil,
        select_class: '',
        wrapper_class: '',
        **attrs
      )
        # Validate inputs
        @form = validate_required!(form, 'form')
        @field = validate_required!(field, 'field')
        @options = validate_required!(options, 'options')
        @label = label
        @prompt = prompt
        @selected = selected
        @multiple = validate_boolean!(multiple, 'multiple')
        @required = validate_boolean!(required, 'required')
        @disabled = validate_boolean!(disabled, 'disabled')
        @help_text = help_text
        @error = error
        @select_class = validate_css_class!(select_class)
        @wrapper_class = validate_css_class!(wrapper_class)

        # Store remaining attrs for select options
        @component_attrs = attrs

        # Use secure attribute extraction
        initialize_component(attrs)
        @html_options = @component_attrs
      end

      def view_template
        code_path 'Renders select component'
        wrapper_attrs = component_attributes(additional_classes: build_wrapper_classes)

        div(**wrapper_attrs) do
          if @label
            code_path 'Renders select with label'
            render_label
          end
          render_select
          if @help_text
            code_path 'Renders select with help text'
            render_help_text
          end
          if @error
            code_path 'Renders select with error'
            render_error
          end
        end
      end

      private

      def render_label
        label(class: 'hs-form-label', for: @field) do
          plain @label
          if @required
            code_path 'Renders required indicator'
            span(class: 'hs-form-required') { '*' }
          end
        end
      end

      def render_select
        code_path 'Renders multiple select' if @multiple
        code_path 'Renders disabled select' if @disabled
        code_path 'Renders select with prompt' if @prompt

        {
          prompt: @prompt,
          selected: @selected
        }.compact

        html_options = build_html_options

        code_path 'Renders static select'
        select(**html_options, name: @field, id: @field) do
          option(value: '') { plain @prompt } if @prompt
          render_options(@options, @selected)
        end
      end

      def render_help_text
        p(class: 'hs-form-help-text') { plain @help_text }
      end

      def render_error
        p(id: "#{@field}-error", class: 'hs-form-error') { plain @error }
      end

      def build_html_options
        options = @html_options.dup
        options[:class] = build_select_classes
        options[:multiple] = @multiple
        options[:required] = @required
        options[:disabled] = @disabled

        # Add aria attributes for accessibility
        if @error
          options[:'aria-invalid'] = 'true'
          options[:'aria-describedby'] = "#{@field}-error"
        end

        options
      end

      def build_select_classes
        classes = ['hs-select']
        if @error
          code_path 'Applies error styling to select'
          classes << 'hs-select-error'
        end
        classes << @select_class
        classes.join(' ').strip
      end

      def build_wrapper_classes
        ['hs-form-group', @wrapper_class]
      end

      def render_options(options, selected_value = nil)
        if options.is_a?(Hash)
          # Grouped options - iterate through groups
          options.each do |group_label, group_options|
            optgroup(label: group_label) do
              render_options(group_options, selected_value)
            end
          end
        elsif options.is_a?(Array)
          options.each do |opt|
            if opt.is_a?(Array)
              # Value/text pair
              value, text = opt
              option(value: value, selected: value == selected_value) { plain text.to_s }
            else
              # Simple option
              option(value: opt, selected: opt == selected_value) { plain opt }
            end
          end
        end
      end
    end
  end
end
