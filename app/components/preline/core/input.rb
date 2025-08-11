# frozen_string_literal: true

module Components
  module Preline
    # A comprehensive Preline UI input component for various form field types.
    # Supports text inputs, textareas, selects, checkboxes, and more with consistent styling.
    # Features model-aware binding for automatic value population and error display.
    #
    # @since 0.1.0
    # @version 0.2.0
    #
    # @example Basic text input with form builder
    #   render Components::Preline::Input.new(
    #     form: form,
    #     field: :email,
    #     type: :email,
    #     label: "Email Address",
    #     placeholder: "you@example.com",
    #     required: true
    #   )
    #
    # @example Model-aware input (NEW in v0.2.0)
    #   render Components::Preline::Input.new(
    #     model: @user,
    #     field: :email,
    #     type: :email,
    #     label: "Email Address"
    #   )  # Automatically binds value and errors from @user
    #
    # @example Input with help text and error
    #   render Components::Preline::Input.new(
    #     form: form,
    #     field: :password,
    #     type: :password,
    #     label: "Password",
    #     help_text: "Must be at least 8 characters",
    #     error: @user.errors[:password].first
    #   )
    #
    # @example Textarea input
    #   render Components::Preline::Input.new(
    #     form: form,
    #     field: :bio,
    #     type: :textarea,
    #     label: "Biography",
    #     placeholder: "Tell us about yourself..."
    #   )
    #
    # @note Version 0.2.0 introduces model-aware binding for automatic value
    #   population and error display without requiring a form builder.
    class Input < ::Components::Preline::PrelineComponent
      # Supported HTML input types
      # @return [Array<Symbol>] List of valid input types
      TYPES = %i[
        text password email number tel url search date datetime time
        month week color file hidden
      ].freeze

      # Initialize a new Input component
      #
      # @param form [ActionView::Helpers::FormBuilder, nil] Rails form builder instance (optional)
      # @param model [ActiveRecord::Base, nil] Model instance for value binding (optional)
      # @param field [Symbol] Form field name or attribute name when using model
      # @param type [Symbol] Input type (:text, :password, :email, :number, :tel, :url, :search, :date, :textarea, :select, :checkbox, :radio, etc.)
      # @param label [String, nil] Field label text
      # @param placeholder [String, nil] Placeholder text
      # @param help_text [String, nil] Help text displayed below the input
      # @param required [Boolean] Mark field as required
      # @param disabled [Boolean] Disable the input
      # @param readonly [Boolean] Make input read-only
      # @param error [String, nil] Error message to display
      # @param class [String] Additional CSS classes for the wrapper
      # @param input_class [String] Additional CSS classes for the input element
      # @param wrapper_class [String] Additional CSS classes for the form group wrapper
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        field:, form: nil, model: nil,
        type: :text,
        label: nil,
        value: nil,
        placeholder: nil,
        help_text: nil,
        required: false,
        disabled: false,
        readonly: false,
        error: nil,
        input_class: '',
        wrapper_class: '',
        **attrs
      )
        # Validate inputs
        @form = form
        @model = model
        @field = validate_required!(field, 'field')
        @type = validate_inclusion!(type, 'type', TYPES + %i[textarea select checkbox radio])
        @label = label
        
        # Handle value: use provided value, or get from model, or get from form object
        @value = value || (@model&.public_send(@field) if @model&.respond_to?(@field)) || (@form&.object&.public_send(@field) if @form&.respond_to?(:object) && @form.object&.respond_to?(@field))
        
        @placeholder = placeholder
        @help_text = help_text
        @required = validate_boolean!(required, 'required')
        @disabled = validate_boolean!(disabled, 'disabled')
        @readonly = validate_boolean!(readonly, 'readonly')
        
        # Handle error: use provided error, or get from model, or get from form object
        @error = error || get_model_error
        
        @input_class = validate_css_class!(input_class)
        @wrapper_class = validate_css_class!(wrapper_class)

        # Store remaining attrs for form options
        @component_attrs = attrs

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      # Renders the complete input component including wrapper, label,
      # input field, help text, and error messages.
      #
      # @return [void]
      # @api public
      def view_template
        wrapper_attrs = component_attributes(additional_classes: build_wrapper_classes)

        div(**wrapper_attrs) do
          render_label if @label
          render_input
          render_help_text if @help_text
          render_error if @error
        end
      end

      private

      # Renders the label element for the input field, using either
      # Rails form builder label or a static label element.
      #
      # @return [void]
      # @api private
      def render_label
        if @form.respond_to?(:label)
          code_path 'Renders Rails form label'
          label_html = if @required
                         # When required, render label with asterisk
                         @form.label(@field, class: 'hs-form-label') do
                           "#{@label} <span class=\"hs-form-required\">*</span>".html_safe
                         end
                       else
                         @form.label(@field, @label, class: 'hs-form-label')
                       end
          raw(safe(label_html.to_s)) if label_html.present?
        else
          code_path 'Renders static label'
          label(class: 'hs-form-label', for: @field) do
            plain @label
            span(class: 'hs-form-required') { '*' } if @required
          end
        end
      end

      # Renders the actual input element using either Rails form builder
      # methods or static HTML elements depending on availability.
      #
      # @return [void]
      # @api private
      def render_input
        input_options = build_input_options

        if @form.respond_to?(:text_field)
          code_path 'Renders Rails form input'
          input_html = case @type
                       when :textarea
                         @form.text_area @field, **input_options
                       when :select
                         @form.select @field, @component_attrs[:options], @component_attrs[:select_options] || {}, input_options
                       when :checkbox
                         return render_checkbox
                       when :radio
                         return render_radio
                       when :file
                         @form.file_field @field, **input_options
                       else
                         @form.send("#{@type}_field", @field, **input_options)
                       end

          raw(safe(input_html.to_s)) if input_html.present?
        else
          code_path 'Renders static input'
          # Fallback to plain HTML input
          input_attrs = input_options.merge(
            type: @type == :textarea ? nil : @type,
            name: input_name,
            value: @value,
            id: @field
          ).compact

          if @type == :textarea
            textarea(**input_attrs)
          else
            input(**input_attrs)
          end
        end
      end

      # Renders a checkbox input with its associated label.
      #
      # @return [void]
      # @api private
      def render_checkbox
        code_path 'Renders checkbox input'
        label(class: 'hs-checkbox') do
          checkbox_html = @form.check_box(@field, class: 'hs-checkbox-input')
          raw(safe(checkbox_html.to_s))
          span(class: 'hs-checkbox-label') { @label || @field.to_s.humanize }
        end
      end

      # Renders radio button inputs for each option provided.
      #
      # @return [void]
      # @api private
      def render_radio
        code_path 'Renders radio input'
        @component_attrs[:options].each do |option|
          label(class: 'hs-radio') do
            radio_html = @form.radio_button(@field, option[:value], class: 'hs-radio-input')
            raw(safe(radio_html.to_s))
            span(class: 'hs-radio-label') { option[:label] }
          end
        end
      end

      # Renders help text below the input field.
      #
      # @return [void]
      # @api private
      def render_help_text
        p(class: 'hs-form-help-text') { plain @help_text }
      end

      # Renders error message for the input field.
      #
      # @return [void]
      # @api private
      def render_error
        p(id: "#{@field}-error", class: 'hs-form-error') { plain @error }
      end

      # Builds the options hash for the input element including
      # classes, attributes, and ARIA properties.
      #
      # @return [Hash] Options hash for the input element
      # @api private
      def build_input_options
        options = @component_attrs.except(:options, :select_options)
        options[:class] = build_input_classes
        options[:placeholder] = @placeholder if @placeholder
        options[:required] = @required
        options[:disabled] = @disabled
        options[:readonly] = @readonly

        # Add aria-describedby for error messages
        if @error
          options[:'aria-describedby'] = "#{@field}-error"
          options[:'aria-invalid'] = 'true'
        end

        options
      end

      # Builds CSS classes for the input element based on type and state.
      #
      # @return [String] Space-separated CSS classes
      # @api private
      def build_input_classes
        classes = case @type
                  when :textarea
                    %w[hs-textarea theme-textarea]
                  when :select
                    %w[hs-select theme-select]
                  else
                    %w[hs-input theme-input]
                  end

        classes << 'hs-input-error' if @error
        classes << @input_class
        classes.join(' ').strip
      end

      # Builds CSS classes for the wrapper div element.
      #
      # @return [Array<String>] Array of CSS classes
      # @api private
      def build_wrapper_classes
        ['hs-form-group', @wrapper_class]
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
