# frozen_string_literal: true

module Components
  module Preline
    # A comprehensive Preline UI select component for dropdown form fields.
    # Supports standard options, grouped options, multiple selection, and full Rails
    # form builder integration. Features model-aware binding for automatic value and
    # error population.
    #
    # @since 0.1.0
    # @version 0.2.0
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
    # @example Model-aware select (NEW in v0.2.0)
    #   render Components::Preline::Select.new(
    #     model: @user,
    #     field: :country,
    #     options: country_options,
    #     label: "Country"
    #   )  # Automatically selects @user.country and shows errors
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
    #
    # @note Version 0.2.0 introduces model-aware binding for automatic value
    #   selection and error display without requiring a form builder.
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
        field:,
        options:,
        form: nil,
        model: nil,
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
        @form = form
        @model = model
        @field = validate_required!(field, 'field')
        @options = validate_required!(options, 'options')
        @label = label
        @prompt = prompt
        
        # Handle selected: use provided value, or get from model, or get from form object
        @selected = selected || get_field_value
        
        @multiple = validate_boolean!(multiple, 'multiple')
        @required = validate_boolean!(required, 'required')
        @disabled = validate_boolean!(disabled, 'disabled')
        @help_text = help_text
        
        # Handle error: use provided error, or get from model, or get from form object
        @error = error || get_model_error
        
        @select_class = validate_css_class!(select_class)
        @wrapper_class = validate_css_class!(wrapper_class)

        # Store remaining attrs for select options
        @component_attrs = attrs

        # Use secure attribute extraction
        initialize_component(attrs)
        @html_options = @component_attrs
      end

      # Renders the complete select component including wrapper, label,
      # select element, help text, and error messages.
      #
      # @return [void]
      # @api public
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

      # Renders the label element for the select field.
      #
      # @return [void]
      # @api private
      def render_label
        label(class: 'hs-form-label', for: @field) do
          plain @label
          if @required
            code_path 'Renders required indicator'
            span(class: 'hs-form-required') { '*' }
          end
        end
      end

      # Renders the select element with options. Supports both Rails form builder
      # integration and standalone usage with model-aware binding.
      #
      # @return [void]
      # @api private
      def render_select
        code_path 'Renders multiple select' if @multiple
        code_path 'Renders disabled select' if @disabled
        code_path 'Renders select with prompt' if @prompt

        html_options = build_html_options

        if @form && @form.respond_to?(:select)
          code_path 'Renders Rails form select'
          select_options = {
            prompt: @prompt,
            selected: @selected
          }.compact
          
          select_html = @form.select(@field, @options, select_options, html_options)
          raw(safe(select_html.to_s)) if select_html.present?
        else
          code_path 'Renders static select'
          select(**html_options, name: input_name, id: @field) do
            option(value: '') { plain @prompt } if @prompt
            render_options(@options, @selected)
          end
        end
      end

      # Renders help text below the select field.
      #
      # @return [void]
      # @api private
      def render_help_text
        p(class: 'hs-form-help-text') { plain @help_text }
      end

      # Renders error message for the select field.
      #
      # @return [void]
      # @api private
      def render_error
        p(id: "#{@field}-error", class: 'hs-form-error') { plain @error }
      end

      # Builds the options hash for the select element including
      # classes, attributes, and ARIA properties.
      #
      # @return [Hash] Options hash for the select element
      # @api private
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

      # Builds CSS classes for the select element based on state.
      #
      # @return [String] Space-separated CSS classes
      # @api private
      def build_select_classes
        classes = ['hs-select']
        if @error
          code_path 'Applies error styling to select'
          classes << 'hs-select-error'
        end
        classes << @select_class
        classes.join(' ').strip
      end

      # Builds CSS classes for the wrapper div element.
      #
      # @return [Array<String>] Array of CSS classes
      # @api private
      def build_wrapper_classes
        ['hs-form-group', @wrapper_class]
      end

      # Recursively renders option elements, supporting simple arrays,
      # value/text pairs, and grouped options.
      #
      # @param options [Array, Hash] The options to render
      # @param selected_value [String, nil] The currently selected value
      # @return [void]
      # @api private
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
      
      # Retrieves the field value from the model or form object if available.
      #
      # @return [String, nil] The field value or nil
      # @api private
      # @since 0.2.0
      def get_field_value
        if @model && @model.respond_to?(@field)
          @model.public_send(@field)
        elsif @form && @form.respond_to?(:object) && @form.object&.respond_to?(@field)
          @form.object.public_send(@field)
        end
      end
      
      # Retrieves error message from the model or form object if available.
      #
      # @return [String, nil] The first error message or nil
      # @api private
      # @since 0.2.0
      def get_model_error
        if @model && @model.respond_to?(:errors) && @model.errors[@field].present?
          @model.errors[@field].first
        elsif @form && @form.respond_to?(:object) && @form.object&.respond_to?(:errors) && @form.object.errors[@field].present?
          @form.object.errors[@field].first
        end
      end
      
      # Generates the appropriate input name attribute for form submission,
      # using Rails conventions for model binding when applicable.
      #
      # @return [String] The input name attribute value
      # @api private
      # @since 0.2.0
      def input_name
        if @model && !@form
          # Generate Rails-style names for model binding
          model_name = @model.model_name.param_key
          "#{model_name}[#{@field}]"
        else
          @field.to_s
        end
      end
    end
  end
end
